# frozen_string_literal: true

require 'rake'

def migration_file_name(name)
  timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  "#{timestamp}_#{name}.rb"
end

def migration_class_name(name)
  name.split('_').map(&:capitalize).join('')
end

def migration_template(name)
  <<~TMP
    module Migrations
      class #{migration_class_name(name)} < Migration
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
desc 'Generate migration'
task :generate_migration, [:name] do |_t, args|
  Dir.chdir('db/migrations')
  file_name = migration_file_name(args[:name])
  file = File.new(file_name, 'w')
  file.write migration_template(args[:name])
  file.close
end

desc 'Database setup'
task :db_setup do
  ruby 'db/setup.rb'
end
