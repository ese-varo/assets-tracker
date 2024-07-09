# frozen_string_literal: true

require_relative '../models/asset'

class AssetsController < ApplicationController
  before do
    authenticate!
  end

  get '/' do
    @assets = Asset.find_by_user_id(current_user.id, as_collection: true)
    haml :'assets/index'
  end

  get '/new' do
    haml :'assets/new'
  end

  get '/:id/edit' do
    @asset = Asset.find_by_id(params[:id])
    raise AssetNotFound unless belongs_to_current_user?(@asset)

    haml :'assets/edit'
  end

  get '/:id' do
    @asset = Asset.find_by_id(params[:id])
    raise AssetNotFound unless belongs_to_current_user?(@asset)

    haml :'assets/asset'
  end

  post '/' do
    data = params_slice_with_sym_keys(:type, :serial_number)
    data[:user_id] = current_user.id

    @asset = Asset.create(**data)
    redirect '/assets'
  rescue AssetValidationError => e
    @errors = e.errors
    haml :'/assets/new'
  end

  put '/:id' do
    data = params_slice_with_sym_keys(:type, :serial_number)

    @asset = Asset.find_by_id(params[:id])
    @asset.update(**data)
    redirect "/assets/#{params['id']}"
  rescue AssetValidationError => e
    @errors = e.errors
    haml :'/assets/edit'
  end

  delete '/:id' do
    Asset.delete(params['id'], current_user.id)
    redirect '/assets'
  end

  helpers do
    def belongs_to_current_user?(asset)
      asset&.user_id == current_user.id
    end
  end
end
