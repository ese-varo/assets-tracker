#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

# This script can be run by executing the db:migrate rake task
Database::Migrator.migrate(DB)
