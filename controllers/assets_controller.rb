class AssetsController < ApplicationController
  before do
    authenticate!
  end

  get '/' do
    @assets = DB.execute( "SELECT * FROM assets" )
    erb :'assets/index'
  end

  get '/new' do
    erb :'assets/new'
  end

  get '/:id/edit' do
    @asset = DB.get_first_row(
      "SELECT * FROM assets WHERE id = ?", params[:id])
    erb :'assets/edit'
  end

  get '/:id' do
    @asset = DB.get_first_row(
      "SELECT * FROM assets WHERE id = ?", params[:id])
    erb :'assets/asset'
  end

  post '/' do
    query = <<-SQL
      INSERT INTO assets (type, serial_number)
      VALUES (?, ?)
    SQL
    DB.execute query, [
      params['type'].capitalize,
      params['serial-number'].upcase
    ]

    redirect '/assets'
  end

  put '/:id' do
    stmt = DB.prepare <<-SQL
      UPDATE assets
      SET
        type = ?,
        serial_number = ?,
        updated_at = (unixepoch('now', 'localtime'))
      WHERE id = ?
    SQL
    stmt.execute params['type'], params['serial_number'], params['id']
    redirect "/assets/#{params['id']}"
  end

  delete '/:id' do
    DB.execute "DELETE FROM assets WHERE id = ?", params['id']
    redirect "/assets"
  end
end
