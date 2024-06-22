require 'bcrypt'

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
    query = "SELECT * FROM users WHERE username = ?"
    @user = DB.get_first_row query, params['username']
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
    query = <<-SQL
      INSERT INTO users (username, email, employee_id, password_hash)
      VALUES (?, ?, ?, ?)
    SQL
    DB.execute query, [
      params['username'],
      params['email'],
      params['employee_id'],
      hash_password(params['password'])
    ]

    redirect '/login'
  end

  helpers do
    def hash_password(password)
      BCrypt::Password.create(password)
    end

    def valid_password?(password_hash, password)
      BCrypt::Password.new(password_hash) == password
    end

    def current_user
      if session[:user_id]
        query = "SELECT * FROM users WHERE id = ?"
        @user ||= DB.get_first_row query, session[:user_id]
      else
        nil
      end
    end
  end
end
