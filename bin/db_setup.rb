#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

Database::Setup.new(DB).run_migrations
