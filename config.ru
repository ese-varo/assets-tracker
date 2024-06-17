require 'bundler'
require_relative 'controllers/application_controller'
require_relative 'controllers/assets_controller'

Bundler.require

use Rack::MethodOverride
use AssetsController
run ApplicationController
