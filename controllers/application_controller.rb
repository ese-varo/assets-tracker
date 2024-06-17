require 'sinatra/base'
require_relative '../config/environment'

class ApplicationController < Sinatra::Base
  configure do
    set :views, Dir.pwd + '/views/'
  end
end
