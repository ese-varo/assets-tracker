require 'sqlite3'
require_relative '../config/environment'

module Migrations
  class Setup
    def initialize(db)
      @db = db
    end

    def run_migrations
      @db.transaction
      migrations.each do |migration|
        clazz = eval(migration.to_s)
        clazz.new(@db).up
      end
      @db.commit
    end

    def migrations
      Dir.chdir('db')
      Dir["migrations/*.rb"].each { |file| require_relative file }
      Migrations.constants.select do |c|
        Migrations.const_get(c).is_a?(Class) &&
          ![:Setup, :Migration].include?(c)
      end
    end
  end

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

