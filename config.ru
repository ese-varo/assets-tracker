# frozen_string_literal: true

require 'bundler'
require 'dotenv/load'
require_relative 'config/environment'

Bundler.require(:default, ENV['APP_ENV'])

use Rack::MethodOverride
use ApplicationController
map('/assets') { run AssetsController }
map('/') { run UsersController }
