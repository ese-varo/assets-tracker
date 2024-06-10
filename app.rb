require 'sinatra'
require 'json'
require 'sqlite3'

class AssetsTracker < Sinatra::Base
  # Open a database
  db = SQLite3::Database.new "test.db"

  # Create a database
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS assets (
      id        INTEGER PRIMARY KEY ASC,
      type      VARCHAR(80),
      username  VARCHAR(50),
      available BOOLEAN
    );
  SQL

  get '/' do
    @assets = db.execute( "SELECT * FROM assets" )

    erb :index
  end

  get '/assets/:id' do
    p "show asset: #{params[:id]}"
  end

  post '/assets' do
    p "add new asset"
  end

  post '/assets/:id' do
    p "modify asset: #{params[:id]}"
  end
end
