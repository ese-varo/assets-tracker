require 'sqlite3'
require 'singleton'

class DatabaseConnection
  include Singleton

  def initialize
    Dir.chdir('./')
    @db = SQLite3::Database.new 'test.db'
    @db.results_as_hash = true
  end

  def connection
    @db
  end
end

DB = DatabaseConnection.instance.connection
