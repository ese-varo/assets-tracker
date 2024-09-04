# frozen_string_literal: true

# Custom Implementation for flash messages shared between requests
class FlashMessages
  def initialize(session)
    @session = session
    @messages = session[:flash] || {}
    @lifetimes = @session[:flash_lifetimes] || 1
    @keep_counter = 0
  end

  def [](index)
    @messages[index]
  end

  def []=(index, value)
    increase_lifetimes if @lifetimes == 1

    @messages[index] = value
    @session[:flash] = @messages
  end

  def empty?
    @lifetimes.zero?
  end

  def each(&)
    @messages.each(&)
  end

  def after_request
    @lifetimes += @keep_counter
    decrease_lifetimes if @lifetimes.positive?
    clear if @lifetimes.zero?
  end

  def keep
    @keep_counter += 1
  end

  private

  def decrease_lifetimes
    @lifetimes -= 1
    @session[:flash_lifetimes] = @lifetimes
  end

  def increase_lifetimes
    @lifetimes += 1
    @session[:flash_lifetimes] = @lifetimes
  end

  def clear
    @session[:flash_lifetimes] = nil
    @session[:flash] = nil
  end
end
