# frozen_string_literal: true

require 'sqlite3'
require_relative '../db/migration'
require_relative 'database_logger'

module Database
  # Handles running the existing migrations
  class Migrator
    attr_reader :db, :logger

    def initialize(db)
      @db = db
      @logger = CustomLogger.new.logger
    end

    def migrate
      db.transaction do
        logger.info('Running migrations')
        history_versions = get_history_versions
        migration_files.each do |file|
          version = get_version(File.basename(file))
          next if history_versions.include?(version)
          execute_migration(file)
          insert_migration(file)
        end
        logger.info("Finished running migrations\n")
      end
    rescue SQLite3::Exception => e
      msg = 'Something went wrong while running migrations: ' \
        "#{e.message}"
      logger.error(msg)
    end

    def execute_migration(filename)
      require filename
      name = get_name(File.basename(filename))
      klass = Migration.const_get(snake_case_to_camel_case(name))
      klass.new(db).up
      logger.info("- #{name} migrated succesfully")
    end

    def snake_case_to_camel_case(text)
      text.split('_').each(&:capitalize!).join('')
    end

    def pending_migrations
      versions = get_history_versions
      pending_count = 0
      logger.info("Looking for pending migrations")
      migration_files.each do |file|
        version = get_version(File.basename(file))
        next if versions.include?(version)
        pending_count += 1
        name = get_name(File.basename(file))
        logger.info("- #{name} migration is pending!")
      end
      logger.info('- No pending migrations') if pending_count == 0
    rescue SQLite3::Exception => e
      msg = 'Something went wrong while verifying pending migrations: ' \
        "#{e.message}"
      logger.error(msg)
    end

    def get_history_versions
      data = db.execute("SELECT version FROM schema_migrations")
      data.map { |row| row['version'] }
    end

    private

    def get_version(filename)
      filename.split('_')[0]
    end

    def get_name(filename)
      filename.sub(/^[^_]*_/, '').split('.')[0]
    end

    def insert_migration(filename)
      name = get_name(File.basename(filename))
      version = get_version(File.basename(filename))
      query = "INSERT INTO schema_migrations (version, name) VALUES (?, ?);"
      db.execute(query, [version, name])
    end

    def migration_files
      Dir.glob(File.join(__dir__, '..', 'db/migrations', '*.rb'))
    end
  end
end
