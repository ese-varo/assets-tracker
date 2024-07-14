# frozen_string_literal: true

require 'sinatra/base'

module Exceptions
  # Custom exception class to handle not found assets
  class AssetNotFound < Sinatra::NotFound
    def initialize
      super(error_message)
    end

    def error_message
      'Asset not found'
    end
  end

  # Custom exception class to handle not found users
  class UserNotFound < Sinatra::NotFound
    def initialize
      super(error_message)
    end

    def error_message
      'User not found'
    end
  end
end
