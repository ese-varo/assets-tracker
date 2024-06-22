require 'sinatra/base'
require 'securerandom'
require_relative '../config/environment'

class ApplicationController < Sinatra::Base
  include Authentication

  configure do
    set :views, Dir.pwd + '/views/'

    enable :admin_access

    enable :sessions
    set :sessions, :expire_after => 86400 # in seconds 1 day
    set :session_store, Rack::Session::Pool
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end
end
