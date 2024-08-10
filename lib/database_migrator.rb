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
        process_migrations(find_pending_migrations)
        logger.info("Finished running migrations\n")
      end
    rescue SQLite3::Exception => e
      msg = 'Something went wrong while running migrations: ' \
            "#{e.message}"
      logger.error(msg)
    end

    def pending_migrations
      pending_migrations = find_pending_migrations
      log_pending_migrations(pending_migrations)
    rescue SQLite3::Exception => e
      msg = 'Something went wrong while verifying pending migrations: ' \
            "#{e.message}"
      logger.error(msg)
    end

    private

    def process_migrations(migrations)
      migrations.each do |file|
        execute_migration(file)
        insert_migration(file)
      end
    end

    def execute_migration(filename)
      require filename
      name = migration_name_from_file(filename)
      klass = Migration.const_get(snake_case_to_camel_case(name))
      klass.new(db).up
      logger.info("- #{name} migrated succesfully")
    end

    def snake_case_to_camel_case(text)
      text.split('_').each(&:capitalize!).join
    end

    def log_pending_migrations(pending_migrations)
      logger.info('Looking for pending migrations')
      if pending_migrations.empty?
        logger.info('- No pending migrations')
      else
        pending_migrations.each do |file|
          name = migration_name_from_file(file)
          logger.info("- #{name} migration is pending!")
        end
      end
    end

    def find_pending_migrations
      versions = history_versions
      migration_files.reject do |file|
        versions.include?(migration_version_from_file(file))
      end
    end

    def history_versions
      data = db.execute('SELECT version FROM schema_migrations')
      data.map { |row| row['version'] }
    end

    def migration_version_from_file(file_path)
      File.basename(file_path).split('_')[0]
    end

    def migration_name_from_file(file_path)
      File.basename(file_path).sub(/^[^_]*_/, '').split('.')[0]
    end

    def insert_migration(filename)
      name = migration_name_from_file(filename)
      version = migration_version_from_file(filename)
      query = 'INSERT INTO schema_migrations (version, name) VALUES (?, ?);'
      db.execute(query, [version, name])
    end

    def migration_files
      Dir.glob(File.join(__dir__, '..', 'db/migrations', '*.rb'))
    end
  end
end
