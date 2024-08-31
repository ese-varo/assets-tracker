# frozen_string_literal: true

require 'csv'

class AssetsController < ApplicationController
  helpers AssetsHelpers
  before do
    authenticate!
  end

  get '/' do
    authorize! to: :index?, on: :Asset
    @assets = AssetDTO.all
    log_index
    haml :'assets/index'
  end

  get '/assigned' do
    @assets = Asset.find_by_user_id(current_user.id, as_collection: true)
    log_assigned
    haml :'assets/assigned'
  end

  get '/pending_requests' do
    authorize! to: :show_pending_requests?, on: :Asset
    @assets = AssetDTO.pending_requests
    log_pending_requests
    haml :'assets/pending_requests'
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

  get '/requested' do
    @pending, @rejected = Asset.requested_by_user(current_user.id)
    log_requested
    haml :'assets/requested'
  end

  get '/:id/edit' do
    @asset = Asset.find_by_id(params[:id])
    @users = User.all
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :update?
    log_form('edit')
    haml :'assets/edit'
  end

  get '/:id' do
    @asset, @user = AssetDTO.find_by_id_with_user(params[:id])
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
    @asset = Asset.create(**data)
    log_create(@asset)
    redirect '/assets'
  rescue Exceptions::AssetValidationError => e
    @errors = e.errors
    log_validation_error('create', @errors)
    haml :'assets/new'
  end

  post '/:id/assign' do
    @asset = Asset.find_by_id(params[:id])
    @requesting_user = User.find_by_id(params[:requesting_user_id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset
    raise Exceptions::UserNotFound.new(params[:requesting_user_id]) unless @requesting_user

    authorize! @asset, to: :update?
    @asset.assign_user(@requesting_user.id)
    @asset_request = AssetDTO.find_request(@asset.id, @requesting_user.id)
    AssetDTO.approve_asset_request(@asset.id, @requesting_user.id) if @asset_request
    log_assign(@asset, @requesting_user)
  rescue Exceptions::AssetRequestError => e
    log_assign_error(@asset, e.message, @requesting_user)
  ensure
    redirect back
  end

  post '/:id/reject' do
    @asset = Asset.find_by_id(params[:id])
    @requesting_user = User.find_by_id(params[:requesting_user_id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset
    raise Exceptions::UserNotFound.new(params[:requesting_user_id]) unless @requesting_user

    authorize! @asset, to: :reject?
    AssetDTO.reject_asset_request(@asset.id, @requesting_user.id)
    log_reject(@asset, @requesting_user)
  rescue Exceptions::AssetRequestError => e
    log_reject_error(@asset, e.message, @requesting_user)
  ensure
    redirect back
  end

  post '/:id/request' do
    @asset = Asset.find_by_id(params[:id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :request?
    @asset.request_by(current_user.id)
    log_request(@asset)
  rescue Exceptions::AssetRequestError => e
    log_request_error(@asset, e.message)
  ensure
    redirect '/assets'
  end

  post '/:id/unassign' do
    @asset = Asset.find_by_id(params[:id])
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :update?
    assigned_user_id = @asset.user_id
    @asset_request = AssetDTO.find_request(@asset.id, assigned_user_id)
    AssetDTO.remove_asset_request(@asset.id, assigned_user_id) if @asset_request
    @asset.unassign_user
    log_unassign(@asset, assigned_user_id)
  rescue Exceptions::AssetRequestError => e
    log_unassign_error(@asset, e.message, assigned_user_id)
  ensure
    redirect back
  end

  put '/:id' do
    data = params_slice_with_sym_keys(:type, :serial_number, :user_id)
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
    raise Exceptions::AssetNotFound.new(params[:id]) unless @asset

    authorize! @asset, to: :destroy?
    @asset.destroy
    log_delete(@asset)
    redirect '/assets'
  end

  delete '/:id/remove_request' do
    @asset_request = AssetDTO.find_request(params[:id], current_user.id)
    raise Sinatra::NotFound, 'Asset Request not found' unless @asset_request

    authorize! @asset_request, to: :remove_request?, on: :Asset
    AssetDTO.remove_asset_request(@asset_request.asset_id, @asset_request.user_id)
    log_remove_request(@asset_request.asset_id, @asset_request.user_id)
  rescue Exceptions::AssetRequestError => e
    log_remove_request_error(@asset_request.asset_id, @asset_request.user_id, e.message)
  ensure
    redirect back
  end
end
