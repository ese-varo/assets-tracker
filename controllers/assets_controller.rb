# frozen_string_literal: true

require_relative '../models/asset'

class AssetsController < ApplicationController
  before do
    authenticate!
  end

  get '/' do
    @assets = Asset.find_by_user_id(current_user['id'])
    erb :'assets/index'
  end

  get '/new' do
    erb :'assets/new'
  end

  get '/:id/edit' do
    @asset = Asset.find(params[:id], current_user['id'])
    raise AssetNotFound unless @asset

    erb :'assets/edit'
  end

  get '/:id' do
    @asset = Asset.find(params[:id], current_user['id'])
    raise AssetNotFound unless @asset

    erb :'assets/asset'
  end

  post '/' do
    data = params_slice_with_sym_keys(:type, :serial_number)
    data[:user_id] = current_user['id']

    @asset = Asset.create(**data)
    redirect '/assets'
  rescue AssetValidationError => e
    @errors = e.errors
    erb :'/assets/new'
  end

  put '/:id' do
    data = params_slice_with_sym_keys(:type, :serial_number)

    @asset = Asset.find(params[:id], current_user['id'])
    @asset.update(**data)
    redirect "/assets/#{params['id']}"
  rescue AssetValidationError => e
    @errors = e.errors
    erb :'/assets/edit'
  end

  delete '/:id' do
    Asset.delete(params['id'], current_user['id'])
    redirect '/assets'
  end
end
