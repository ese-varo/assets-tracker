require 'sinatra'
require 'json'
require 'sqlite3'

class AssetsTracker < Sinatra::Base
  use Rack::MethodOverride

  # Open a database
  db = SQLite3::Database.new "test.db"
  db.results_as_hash = true

  # Create a database
  stmt = db.prepare <<-SQL
    CREATE TABLE IF NOT EXISTS assets (
      id            INTEGER PRIMARY KEY ASC,
      serial_number VARCHAR(80) NOT NULL,
      type          VARCHAR(80) NOT NULL,
      username      VARCHAR(50) DEFAULT NULL,
      available     BOOLEAN DEFAULT 1
    );
  SQL
  stmt.execute
  stmt.close

  get '/' do
    @assets = db.execute( "SELECT * FROM assets" )

    erb :index
  end

  get '/assets/:id' do
    @asset = db.get_first_row "SELECT * FROM assets WHERE id = ?", params[:id]

    erb :asset
  end

  post '/assets' do
    p "add new asset"
  end

  post '/assets/:id' do
    p "modify asset: #{params[:id]}"
  end
end
