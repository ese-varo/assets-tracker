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

  get '/assets/new' do
    erb :new
  end

  get '/assets/:id/edit' do
    @asset = db.get_first_row "SELECT * FROM assets WHERE id = ?", params[:id]

    erb :edit
  end

  get '/assets/:id' do
    @asset = db.get_first_row "SELECT * FROM assets WHERE id = ?", params[:id]

    erb :asset
  end

  post '/assets' do
    query = <<-SQL
      INSERT INTO assets (type, serial_number)
      VALUES (?, ?)
    SQL
    db.execute query, [
      params['type'].capitalize,
      params['serial-number'].upcase
    ]

    redirect '/'
  end

  put '/assets/:id' do
    stmt = db.prepare <<-SQL
      UPDATE assets
      SET type = ?, serial_number = ?, updated_at = (unixepoch())
      WHERE id = ?
    SQL
    stmt.execute params['type'], params['serial_number'], params['id']

    redirect "/assets/#{params['id']}"
  end

  delete '/assets/:id' do
    db.execute "DELETE FROM assets WHERE id = ?", params['id']

    redirect "/"
  end
end
