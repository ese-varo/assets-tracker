# frozen_string_literal: true

require 'csv'

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

  get '/upload_csv' do
    authorize! to: :show_upload_csv?, on: :Asset
    log_form('upload csv')
    haml :'assets/upload_csv'
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

  post '/upload_csv' do
    authorize! to: :upload_csv?, on: :Asset
    @errors = []
    logger_wrapper = LoggerWrapper.new(logger, env['correlation_id'])
    assets_csv = params[:file][:tempfile]
    begin
      result = CSVAssetImporterService.call(assets_csv, DB, logger_wrapper)
      @errors << result.error unless result.success?
    rescue Exceptions::AssetValidationError => e
      @errors.push(*e.errors)
    end
    haml :'assets/upload_csv'
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
    log_delete(@asset)
    redirect '/assets'
  end
end
