# frozen_string_literal: true

require 'bundler'
require 'dotenv/load'
Bundler.require(:default, ENV.fetch('APP_ENV'))
require_relative '../lib/utils'

require_all 'lib'
require_all 'helpers'
require_all 'errors', sort_by_pattern: /application/
require_all 'policies', sort_by_pattern: /application/
require_all 'models', sort_by_pattern: /model/
require_all 'services', sort_by_pattern: /base/
require_all 'controllers', sort_by_pattern: /application/
require_all 'jobs', sort_by_pattern: /scheduler/

DB = Database::Connection.instance.connection
SCHEDULER = JobScheduler.new
SCHEDULER.run
