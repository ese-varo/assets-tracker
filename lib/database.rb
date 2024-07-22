# frozen_string_literal: true

require 'sqlite3'
require 'singleton'
require_relative '../db/migration'

module Database
  # singleton class to handle the db connection in the entire app
  class Connection
    include Singleton

    def initialize
      @db = SQLite3::Database.new(ENV['DB_NAME'] || 'db/test.db')
      @db.results_as_hash = true
    end

    def connection
      @db
    end
  end

  # Handles running the existing migrations
  class Migrator
    class << self
      def migrate(db)
        db.transaction
        migrations.each do |migration|
          clazz = Migration.const_get(migration.to_s)
          clazz.new(db).up
        end
        db.commit
      rescue StandardError => e
        db.rollback
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
        Dir.glob(File.join(__dir__, '..', 'db/migrations', '*.rb'))
      end
    end
  end
end
