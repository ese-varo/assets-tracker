require 'rspec'
require 'rack/test'

RSpec.describe 'My Sinatra App' do
  include Rack::Test::Methods

  it 'returns a successful response from login page' do
    get '/login'
    expect(last_response).to be_ok
  end
end
