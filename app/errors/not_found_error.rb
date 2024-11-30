# frozen_string_literal: true

require 'sinatra/base'

class UserNotFound < Sinatra::NotFound; end
class AssetNotFound < Sinatra::NotFound; end
