# frozen_string_literal: true

require 'sinatra/base'

module Exceptions
  class AssetNotFound < Sinatra::NotFound; end
  class UserNotFound < Sinatra::NotFound; end
end
