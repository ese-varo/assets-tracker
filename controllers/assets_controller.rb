# frozen_string_literal: true

require_relative '../models/asset'

class AssetsController < ApplicationController
  before do
    authenticate!
  end

  get '/' do
    authorize! to: :index?, on: :Asset
    @assets = Asset.all
    haml :'assets/index'
  end

  get '/new' do
    authorize! to: :new?, on: :Asset
    haml :'assets/new'
  end

  get '/:id/edit' do
    @asset = Asset.find_by_id(params[:id])
    raise AssetNotFound unless @asset
    authorize! @asset, to: :update?

    haml :'assets/edit'
  end

  get '/:id' do
    @asset = Asset.find_by_id(params[:id])
    raise AssetNotFound unless @asset
    authorize! @asset, to: :show?

    haml :'assets/asset'
  end

  post '/' do
    authorize! to: :create?, on: :Asset
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
    authorize! @asset, to: :update?
    @asset.update(**data)
    redirect "/assets/#{params['id']}"
  rescue AssetValidationError => e
    @errors = e.errors
    haml :'/assets/edit'
  end

  delete '/:id' do
    @asset = Asset.find_by_id(params[:id])
    authorize! @asset, to: :destroy?
    @asset.destroy
    redirect '/assets'
  end
end
