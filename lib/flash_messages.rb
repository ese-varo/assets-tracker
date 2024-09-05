# frozen_string_literal: true

# Custom Implementation for flash messages shared between requests
class FlashMessages
  attr_reader :messages, :lifetimes

  def initialize(messages, lifetimes)
    @messages = messages || {}
    @lifetimes = lifetimes || 1
    @keep_counter = 0
  end

  def [](index)
    @messages[index]
  end

  def []=(index, value)
    increase_lifetimes if @lifetimes == 1

    @messages[index] = value
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
  end

  def keep
    @keep_counter += 1
  end

  def clear?
    @lifetimes.zero?
  end

  private

  def decrease_lifetimes
    @lifetimes -= 1
  end

  def increase_lifetimes
    @lifetimes += 1
  end
end
