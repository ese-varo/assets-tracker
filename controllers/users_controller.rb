# frozen_string_literal: true

require 'bcrypt'

# Handles all users and authentication related requests
class UsersController < ApplicationController
  before do
    pass if %w[login signup logout].include? request.path_info.split('/')[1]
    authenticate!
  end

  get '/users' do
    authorize! to: :index?, on: :User
    @users = User.all
    haml :'users/index'
  end

  get '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    authorize! @user, to: :update?
    haml :'users/edit'
  end

  get '/users/:id' do
    @user = User.find_by_id(params[:id])
    raise UserNotFound unless @user
    authorize! to: :show?, on: :User
    haml :'users/user'
  end

  put '/users/:id' do
    data = params_slice_with_sym_keys(:username, :email, :employee_id, :role)

    @user = User.find_by_id(params[:id])
    authorize! @user, to: :update?
    @user.update(**data)
    redirect "/users/#{params['id']}"
  rescue UserValidationError => e
    @errors = e.errors
    haml :'/users/edit'
  end

  get '/login' do
    redirect '/assets' if authenticated?
    haml :'users/login'
  end

  post '/login' do
    @user = User.find_by_username(params['username'])
    if @user && valid_password?(@user.password_hash, params['password'])
      original_request = session[:original_request]
      session.clear
      session[:user_id] = @user.id

      redirect to(original_request) if original_request
      redirect '/assets'
    else
      @error = 'Incorrect authentication credentials'
      haml :'/users/login'
    end
  end

  post '/logout' do
    session.clear
    redirect '/login'
  end

  get '/signup' do
    redirect back if authenticated?
    haml :'users/signup'
  end

  post '/signup' do
    @errors = []
    unless params['password'] == params['password_confirmation']
      @errors << "Passwords doesn't match"
      return haml :'users/signup'
    end
    User.create!(**params_slice_with_sym_keys(
      :username, :email, :employee_id, :password
    ))
    redirect '/login'
  rescue UserValidationError => e
    @errors = e.errors
    haml :'users/signup'
  end

  helpers do
    def valid_password?(password_hash, password)
      BCrypt::Password.new(password_hash) == password
    end
  end
end
