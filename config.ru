require 'bundler'

Bundler.require

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(:subclasses=>%w'Sinatra::Base'){AssetsTracker}
Unreloader.require './app.rb'

run Unreloader
