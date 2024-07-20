# frozen_string_literal: true

require 'sinatra/base'

module Exceptions
  # Abstract not found class
  class NotFound < Sinatra::NotFound
    attr_reader :id

    def initialize(id)
      @id = id
      super(error_message)
    end

    def error_message
      raise NotImplementedError
    end
  end

  # Custom exception class to handle not found assets
  class AssetNotFound < NotFound
    def error_message
      "Asset with ID #{id} not found"
    end
  end

  # Custom exception class to handle not found users
  class UserNotFound < NotFound
    def error_message
      "User with ID #{id} not found"
    end
  end
end
