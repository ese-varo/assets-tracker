# frozen_string_literal: true

require_relative '../lib/utils'
require_all_from_dir('lib')
require_all_from_dir('errors')
require_all_from_dir('policies', sort_by_pattern: /application/)
require_all_from_dir('models', sort_by_pattern: /model/)
require_all_from_dir('controllers', sort_by_pattern: /application/)

DB = Database::Connection.instance.connection
