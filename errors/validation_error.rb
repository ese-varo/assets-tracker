# frozen_string_literal: true

module Exceptions
  # class to handle model validation errors
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors, generic_message = '')
      super(generic_message)
      @errors = errors
    end
  end

  class UserValidationError < ValidationError; end
  class AssetValidationError < ValidationError; end
end
