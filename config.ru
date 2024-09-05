# frozen_string_literal: true

require_relative 'config/environment'

use Rack::MethodOverride
use ApplicationController
use FlashMiddleware, ApplicationController.settings.error_logger
map('/assets') { run AssetsController }
map('/') { run UsersController }
