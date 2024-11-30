# frozen_string_literal: true

require 'bcrypt'

# Handles all users and authentication related requests
class UsersController < ApplicationController
  helpers UsersHelpers
  before do
    authenticate! unless request_path_is_public?
  end

  get '/users' do
    authorize! to: :index?, on: :User
    @users = User.all
    log_index(@users)
    haml :'users/index'
  end

  get '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    raise UserNotFound, "User with ID #{params[:id]} not found" unless @user

    authorize! @user, to: :update?
    log_edit(@user)
    haml :'users/edit'
  end

  get '/users/:id' do
    @user = User.find_by_id(params[:id])
    raise UserNotFound, "User with ID #{params[:id]} not found" unless @user

    authorize! @user, to: :show?
    log_show(@user)
    haml :'users/user'
  end

  put '/users/:id' do
    data = params_slice_with_sym_keys(:username, :email, :employee_id, :role)
    @user = User.find_by_id(params[:id])
    authorize! @user, to: :update?
    @user.update(**data)
    log_update(@user)
    redirect "/users/#{params['id']}"
  rescue UserValidationError => e
    @errors = e.errors
    log_validation_error('update', @errors)
    haml :'users/edit'
  end

  get '/login' do
    redirect '/assets' if authenticated?
    log_login
    haml :'users/login'
  end

  post '/login' do
    @user = User.find_by_username(params['username'])
    if @user && valid_password?(@user.password_hash, params['password'])
      original_request = session[:original_request]
      session.clear
      session[:user_id] = @user.id
      log_login_post

      redirect to(original_request) if original_request
      redirect '/assets'
    else
      @error = 'Incorrect authentication credentials'
      log_login_post(@error)
      haml :'users/login'
    end
  end

  post '/logout' do
    log_logout
    session.clear
    redirect '/login'
  end

  get '/signup' do
    redirect back if authenticated?
    log_signup
    haml :'users/signup'
  end

  post '/signup' do
    @errors = []
    unless params['password'] == params['password_confirmation']
      @errors << "Passwords doesn't match"
      raise UserValidationError.new(@errors, User.create_err)
    end
    @user = User.create!(**params_slice_with_sym_keys(
      :username, :email, :employee_id, :password
    ))
    log_create(@user)
    redirect '/login'
  rescue UserValidationError => e
    @errors = e.errors
    log_validation_error('create', @errors)
    haml :'users/signup'
  end

  delete '/users/:id' do
    @user = User.find_by_id(params[:id])
    authorize! @user, to: :destroy?
    @user.destroy
    log_delete(@user)
    redirect '/users'
  end
end
