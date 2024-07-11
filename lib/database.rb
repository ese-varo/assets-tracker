# frozen_string_literal: true

require 'sqlite3'
require 'singleton'
require_relative '../db/migration'

# This script can be run by executing the db_setup rake task
# as follows: rake db_setup
# Handles the setup of the database
# this is meant to be used in fresh installations.
module Database
  class Connection
    include Singleton

    def initialize
      Dir.chdir('./')
      @db = SQLite3::Database.new(ENV['DB_NAME'] || 'db/test.db')
      @db.results_as_hash = true
    end

    def connection
      @db
    end
  end

  class Setup
    def initialize(db)
      @db = db
    end

    def run_migrations
      @db.transaction
      migrations.each do |migration|
        clazz = Migration.const_get(migration.to_s)
        clazz.new(@db).up
      end
      @db.commit
    rescue StandardError => e
      @db.rollback
      puts "Error running migrations: #{e.message}"
    end

    private

    def migrations
      migration_files.each { |file| require file }
      Migration.constants.select do |c|
        Migration.const_get(c).is_a?(Class) && c != :Base
      end
    end

    def migration_files
      Dir.glob("#{Dir.pwd}/db/migrations/*.rb")
    end
  end
end
