# frozen_string_literal: true

require 'sinatra/base'
require 'securerandom'
require_relative '../config/environment'

class AssetNotFound < Sinatra::NotFound; end

# Main app controller. All controllers inherit from this one.
# It adds basic configuration and functionality needed in the controllers
class ApplicationController < Sinatra::Base
  include Authentication

  configure do
    set :views, File.expand_path('../views', __dir__)
    set :haml, format: :html5

    enable :admin_access

    enable :sessions
    set :sessions, expire_after: 86_400 # in seconds 1 day
    set :session_store, Rack::Session::Pool
    set :session_secret, ENV['SESSION_SECRET'] { SecureRandom.hex(64) }
  end

  configure :development do
    set :show_exceptions, :after_handler
    # set :show_exceptions, false
  end

  not_found do
    "This is nowhere to be found - #{env['sinatra.error'].message}"
  end

  error AssetNotFound do
    halt 404, 'NotFound: asset not found'
  end

  error do
    "Sorry there was an error - #{env['sinatra.error'].message}"
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
