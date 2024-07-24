# frozen_string_literal: true

require 'sqlite3'

module Database
  # singleton class to handle the db connection in the entire app
  class Connection
    include Singleton

    def initialize
      @db = SQLite3::Database.open(ENV['DB_NAME'] || 'db/test.db')
      @db.results_as_hash = true
    end

    def connection
      @db
    end
  end
end
