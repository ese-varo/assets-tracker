require 'sinatra'
require 'json'

class AssetsTracker < Sinatra::Base
  get '/' do
    @assets = [
      {
        type: 'mouse',
        username: 'tyler',
        available: false,
      },
      {
        type: 'pc',
        username: nil,
        available: true,
      }
    ]

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
