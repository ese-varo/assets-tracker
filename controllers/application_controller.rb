# frozen_string_literal: true

require 'sinatra/base'
require 'securerandom'
require_relative '../config/environment'

# Main app controller. All controllers inherit from this one.
# It adds basic configuration and functionality needed in the controllers
class ApplicationController < Sinatra::Base
  include Authentication

  configure do
    set :views, File.expand_path('../views', __dir__)

    enable :admin_access

    enable :sessions
    set :sessions, expire_after: 86_400 # in seconds 1 day
    set :session_store, Rack::Session::Pool
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end

  helpers do
    # return specified params with keys as symbols
    def params_slice_with_sym_keys(*keys)
      params.slice(*keys).to_h.transform_keys(&:to_sym)
    end
  end
end
