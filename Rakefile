# frozen_string_literal: true

require 'rake'

def migration_file_name(name)
  timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  "#{timestamp}_#{name}.rb"
end

def migration_class_name(name)
  name.split('_').map(&:capitalize).join
end

def migration_template(name)
  <<~TMP
    # frozen_string_literal: true

    module Migration
      class #{migration_class_name(name)} < Base
        def up
        end

        def down
        end
      end
    end
  TMP
end

# Usage
# cli example command: rake task_name[migration_class_name]
# e.g. rake generate_migration[create_users]
namespace :db do
  desc 'App environment'
  task :environment do
    require_relative 'config/environment'
  end

  desc 'Generate migration'
  task :generate_migration, [:name] do |_t, args|
    file_name = migration_file_name(args[:name])
    file = File.new(File.join(__dir__, '/db/migrations/', file_name), 'w')
    file.write migration_template(args[:name])
    file.close
  end

  desc 'Migrate database'
  task :migrate do
    ruby 'bin/db_migrate.rb'
  end

  desc 'Setup database'
  task setup: :environment do
    db_connection = Database::Connection.instance.connection
    Database::Setup.new(db_connection).execute
  end

  desc 'Pending migrations'
  task pending_migrations: :environment do
    db_connection = Database::Connection.instance.connection
    Database::Migrator.new(db_connection).pending_migrations
  end
end
