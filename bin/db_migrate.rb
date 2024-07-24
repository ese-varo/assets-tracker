#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

# This script can be run by executing the db:migrate rake task
db_connection = Database::Connection.instance.connection
Database::Migrator.new(db_connection).migrate
