require 'bundler'

Bundler.require

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new{AssetsTracker}
Unreloader.require './app.rb'

run Unreloader
