# frozen_string_literal: true

# Module to handle authentication functionality
module Authentication
  def authenticate!
    return if authorized?

    # halt 401, 'Not authorized'
    session[:original_request] = request.path
    redirect '/login'
  end

  def authorized?
    !!session[:user_id]
  end
end
