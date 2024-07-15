# frozen_string_literal: true

require_relative 'config/environment'

use Rack::MethodOverride
use ApplicationController
map('/assets') { run AssetsController }
map('/') { run UsersController }
