# frozen_string_literal: true

require_relative '../models/asset'

# Handles all assets related requests
class AssetsController < ApplicationController
  before do
    authenticate!
  end

  get '/' do
    @assets = Asset.all
    erb :'assets/index'
  end

  get '/new' do
    erb :'assets/new'
  end

  get '/:id/edit' do
    @asset = Asset.find(params[:id])
    erb :'assets/edit'
  end

  get '/:id' do
    @asset = Asset.find(params[:id])
    erb :'assets/asset'
  end

  post '/' do
    Asset.create(params['type'], params['serial_number'])
    redirect '/assets'
  end

  put '/:id' do
    Asset.update(**params_slice_with_sym_keys(:id, :type, :serial_number))
    redirect "/assets/#{params['id']}"
  end

  delete '/:id' do
    Asset.delete(params['id'])
    redirect '/assets'
  end
end
