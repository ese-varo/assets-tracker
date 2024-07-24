# frozen_string_literal: true

require 'sqlite3'
require_relative 'database_logger'
require_relative 'database_migrator'

module Database
  # this setup is meant to be used on fresh new installations
  # there is a rake task to take care of this process: db:setup
  class Setup
    attr_reader :logger, :db

    def initialize(db)
      @db = db
      @logger = CustomLogger.new.logger
    end

    def execute
      create_db
      create_schema_migrations_table
      run_migrations
    end

    def create_db
      logger.info('Creating database')
      SQLite3::Database.new(ENV['DB_NAME'] || 'db/test.db')
      logger.info("Database #{db_name} successfully created\n")
    rescue SQLite3::Exception => e
      msg = "Something went wrong while creating the database: #{e.message}"
      logger.error(msg)
    end

    def create_schema_migrations_table
      logger.info('Creating schema_migrations table')
      db.execute create_schema_migrations_query
      logger.info("Table schema_migrations successfully created\n")
    rescue SQLite3::Exception => e
      msg = 'Something went wrong while creating schema_migrations table: ' \
        "#{e.message}"
      logger.error(msg)
    end

    def run_migrations
      Migrator.new(db).migrate
    end

    private

    def db_name
      filename = ENV['DB_NAME'] || 'db/test.db'
      File.basename(filename).split('.')[0]
    end

    def create_schema_migrations_query
      <<-SQL
        CREATE TABLE schema_migrations (
          id      INTEGER PRIMARY KEY ASC,
          version VARCHAR(20) UNIQUE NOT NULL,
          name    VARCHAR(255) NOT NULL
        );
      SQL
    end
  end
end
