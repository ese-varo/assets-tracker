# frozen_string_literal: true

class AssetsController < ApplicationController
  helpers AssetsHelpers
  before do
    authenticate!
  end

  get '/' do
    authorize! to: :index?, on: :Asset
    @assets = Asset.all
    log_index
    haml :'assets/index'
  end

  get '/assigned' do
    @assets = Asset.find_by_user_id(current_user.id, as_collection: true)
    log_assinged
    haml :'assets/index'
  end

  get '/new' do
    authorize! to: :new?, on: :Asset
    log_form('new')
    haml :'assets/new'
  end

  get '/:id/edit' do
    @asset = Asset.find_by_id(params[:id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :update?
    log_form('edit')
    haml :'assets/edit'
  end

  get '/:id' do
    @asset = Asset.find_by_id(params[:id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :show?
    log_show
    haml :'assets/asset'
  end

  post '/' do
    authorize! to: :create?, on: :Asset
    data = params_slice_with_sym_keys(:type, :serial_number)
    data[:user_id] = current_user.id
    @asset = Asset.create(**data)
    log_create(@asset)
    redirect '/assets'
  rescue Exceptions::AssetValidationError => e
    @errors = e.errors
    log_validation_error('create', @errors)
    haml :'assets/new'
  end

  put '/:id' do
    data = params_slice_with_sym_keys(:type, :serial_number)
    @asset = Asset.find_by_id(params[:id])
    authorize! @asset, to: :update?
    @asset.update(**data)
    log_update(@asset)
    redirect "/assets/#{params['id']}"
  rescue Exceptions::AssetValidationError => e
    @errors = e.errors
    log_validation_error('update', @errors)
    haml :'assets/edit'
  end

  delete '/:id' do
    @asset = Asset.find_by_id(params[:id])
    authorize! @asset, to: :destroy?
    @asset.destroy
    log_delete
    redirect '/assets'
  end
end
