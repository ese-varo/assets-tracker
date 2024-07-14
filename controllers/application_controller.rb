# frozen_string_literal: true

require 'sinatra/base'
require 'securerandom'

# Main app controller. All controllers inherit from this one.
# It adds basic configuration and functionality needed in the controllers
class ApplicationController < Sinatra::Base
  include Authentication

  ONE_DAY_IN_SECONDS = 86_400
  configure do
    set :views, File.expand_path('../views', __dir__)
    set :haml, format: :html5

    enable :sessions
    set :sessions, expire_after: ONE_DAY_IN_SECONDS
    set :session_store, Rack::Session::Pool
    set :session_secret, ENV['SESSION_SECRET'] { SecureRandom.hex(64) }
  end

  configure :development do
    set :show_exceptions, :after_handler
    # set :show_exceptions, false
  end

  not_found do
    status 404
    @error_message = env['sinatra.error'].message
    haml :not_found
  end

  error Exceptions::UnauthorizedAction do
    status 403
    @error_message = env['sinatra.error'].message
    haml :unauthorized
  end

  error do
    status 500
    @error_message = 'Something went wrong. Our team is working on it.'
    haml :server_error
  end

  helpers do
    def current_user
      return unless session[:user_id]

      @current_user ||= User.find_by_id(session[:user_id])
    end

    # return specified params with keys as symbols
    def params_slice_with_sym_keys(*keys)
      params.slice(*keys).to_h.transform_keys(&:to_sym)
    end

    def partial(template, locals = {})
      haml(:"partials/#{template}", locals: locals)
    end
  end
end
