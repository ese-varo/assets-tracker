# frozen_string_literal: true

require 'sinatra/base'
require 'securerandom'
require 'logger'

# Main app controller. All controllers inherit from this one.
# It adds basic configuration and functionality needed in the controllers
class ApplicationController < Sinatra::Base
  include Authentication
  helpers ApplicationHelpers

  ONE_DAY_IN_SECONDS = 86_400
  LOG_DIR = File.expand_path('../logs', __dir__)
  VIEWS_DIR = File.expand_path('../views', __dir__)
  SESSION_SECRET = ENV['SESSION_SECRET'] || SecureRandom.hex(64)

  def self.logging_configure
    FileUtils.mkdir_p(LOG_DIR)

    req_logger = build_logger('requests', 'weekly')
    use CorrelatedCommonLogger, req_logger

    app_logger = build_logger('application', 'weekly')
    app_logger.info '====== Booting up ======'
    set :logger, app_logger

    error_logger = build_logger('errors', 'monthly')
    set :error_logger, error_logger
  end

  def self.build_logger(name, rotation_frequency)
    log_file_path = File.join(LOG_DIR, "#{name}.log")
    begin
      log_file = File.new(log_file_path, 'a+')
      log_file.sync = true
      Logger.new(log_file, rotation_frequency)
    rescue StandarError => e
      puts "Error creating #{name} logger: #{e.message}"
      nil
    end
  end

  configure do
    set :views, VIEWS_DIR
    set :haml, format: :html5

    enable :sessions
    set :sessions, expire_after: ONE_DAY_IN_SECONDS
    set :session_store, Rack::Session::Cookie
    set :session_secret, SESSION_SECRET

    enable :protection
    use Rack::Protection::AuthenticityToken

    enable :logging
    ApplicationController.logging_configure

    set :flash, {}
  end

  configure :development do
    set :logging, Logger::DEBUG
    set :show_exceptions, :after_handler
    # set :show_exceptions, false
  end

  configure :production do
    set :logging, Logger::INFO
  end

  at_exit do
    logger.info '====== Shutting down ======'
  end

  before do
    env['correlation_id'] = SecureRandom.uuid
    set_flash
  end

  after do
    flash&.after_request
  end

  not_found do
    @error_message = env['sinatra.error'].message
    log_not_found
    status 404
    haml :not_found
  end

  error UnauthorizedAction do
    error = env['sinatra.error']
    @error_message = error.message
    logger.warn(with_cid(error.log_message))
    status 403
    haml :unauthorized
  end

  error do
    log_generic_error
    status 500
    @error_message = 'Something went wrong. Our team is working on it.'
    haml :server_error
  end
end
