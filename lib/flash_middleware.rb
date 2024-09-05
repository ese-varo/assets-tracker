# frozen_string_literal: true

require_relative 'flash_messages'

# Custom middleware to handle flash messages integration
class FlashMiddleware
  def initialize(app, logger = nil)
    @app = app
    @logger = logger || Logger.new($stdout)
  end

  def call(env)
    flash = build_flash_from_session(env)
    status, headers, body = @app.call(env)
    [status, headers, body]
  rescue StandardError => e
    @logger.error("Error in FlashMiddleware: #{e.message}")
    raise
  ensure
    flash_cleanup(env, flash)
  end

  private

  def flash_cleanup(env, flash)
    if flash
      flash.after_request
      flash.clear? ? clear_flash_from_session(env) : set_flash_in_session(env, flash)
    end
  rescue StandardError => e
    @logger.error("Error in FlashMiddleware cleanup: #{e.message}")
  end

  def build_flash_from_session(env)
    flash = FlashMessages.new(flash_session(env), flash_lifetimes_session(env))
    env['sinatra.flash'] = flash
    flash
  rescue StandardError => e
    @logger.error("Error building flash from session: #{e.message}")
    nil
  end

  def set_flash_in_session(env, flash)
    env['rack.session'][:flash] = flash.messages
    env['rack.session'][:flash_lifetimes] = flash.lifetimes
  end

  def clear_flash_from_session(env)
    env['rack.session'].delete(:flash)
    env['rack.session'].delete(:flash_lifetimes)
  end

  def flash_session(env)
    env['rack.session'][:flash]
  end

  def flash_lifetimes_session(env)
    env['rack.session'][:flash_lifetimes]
  end
end
