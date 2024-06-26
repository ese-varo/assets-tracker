# frozen_string_literal: true

require 'bundler'
require 'dotenv/load'

require_relative 'lib/authentication'
# load main app controller file
require_relative 'controllers/application_controller'

# load the rest of the controllers
Dir['./controllers/*.rb'].each do |file|
  require file unless file.match(/application_controller/)
end

Bundler.require(:default, ENV['APP_ENV'])

use Rack::MethodOverride
use ApplicationController
map('/assets') { run AssetsController }
map('/') { run UsersController }
