#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

# This script can be run by executing the db_setup rake task
# as follows: rake db_setup
Database::Setup.new(DB).run_migrations
