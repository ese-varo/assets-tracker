# frozen_string_literal: true

require 'bundler'
require 'dotenv/load'
Bundler.require(:default, ENV.fetch('APP_ENV'))
require_relative '../lib/utils'

require_all 'lib'
require_all 'app/helpers'
require_all 'app/errors', sort_by_pattern: /application/
require_all 'app/policies', sort_by_pattern: /application/
require_all 'app/models', sort_by_pattern: /model/
require_all 'app/services', sort_by_pattern: /base/
require_all 'app/controllers', sort_by_pattern: /application/

DB = Database::Connection.instance.connection
