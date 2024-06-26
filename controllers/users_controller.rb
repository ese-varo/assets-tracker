# frozen_string_literal: true

require 'bcrypt'
require_relative '../models/user'

# Handles all users and authentication related requests
class UsersController < ApplicationController
  before do
    pass if %w[login signup logout].include? request.path_info.split('/')[1]
    authenticate!
  end

  get '/login' do
    redirect '/assets' if authorized?
    erb :'users/login'
  end

  post '/login' do
    @user = User.find_by_username(params['username'])
    if @user && valid_password?(@user['password_hash'], params['password'])
      original_request = session[:original_request]
      session.clear
      session[:user_id] = @user['id']

      redirect to(original_request) if original_request
      redirect '/assets'
    else
      @error = 'Incorrect authentication credentials'
      erb :'/users/login'
    end
  end

  post '/logout' do
    session.clear
    redirect '/login'
  end

  get '/signup' do
    redirect back if authorized?
    erb :'users/signup'
  end

  post '/signup' do
    User.create(**params_slice_with_sym_keys(
      :username, :email, :employee_id, :password
    ))

    redirect '/login'
  end

  helpers do
    def valid_password?(password_hash, password)
      BCrypt::Password.new(password_hash) == password
    end
  end
end
