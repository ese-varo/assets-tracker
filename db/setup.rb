# frozen_string_literal: true

require 'sqlite3'
require_relative '../config/environment'

# This script can be run by executing the db_setup rake task
# as follows: rake db_setup
module Migrations
  # Handles the setup of the database
  # this is meant to be used in fresh installations.
  class Setup
    def initialize(db)
      @db = db
    end

    def run_migrations
      @db.transaction
      migrations.each do |migration|
        clazz = Migrations.const_get(migration.to_s)
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
      Migrations.constants.select do |c|
        Migrations.const_get(c).is_a?(Class) &&
          !%I[Setup Migration].include?(c)
      end
    end

    def migration_files
      Dir.glob("#{Dir.pwd}/db/migrations/*.rb")
    end
  end

  # New migration classes inherit from this class
  class Migration
    def initialize(db)
      @db = db
    end

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end

Migrations::Setup.new(DB).run_migrations
