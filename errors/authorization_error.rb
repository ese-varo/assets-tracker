# frozen_string_literal: true

module Exceptions
  # custom unauthorized exception
  class UnauthorizedAction < StandardError
    def initialize(action)
      super(error_message(action))
    end

    private

    def error_message(action)
      message = "You are not authorized to #{action}"
      p "responds to message: #{respond_to?('message')}"
      p "responds to message=: #{respond_to?('message=')}"
      p message
      message
    end
  end
end
