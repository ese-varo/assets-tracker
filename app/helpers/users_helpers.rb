# frozen_string_literal: true

# User only helpers
module UsersHelpers
  def valid_password?(password_hash, password)
    BCrypt::Password.new(password_hash) == password
  end

  def public_paths
    %w[/login /signup /logout]
  end

  def sensitive_params
    %w[password password_confirmation]
  end

  def log_index(users)
    msg = 'User: INDEX | Users list accessed | ' \
          "Users Count: #{users.count} | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_edit(user)
    msg = "User: EDIT | Requested edit form for User with ID #{user.id} " \
          "(username: #{user.username}) | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_show(user)
    msg = 'User: READ | User details accessed for User with ' \
          "ID #{user.id} (username: #{user.username}) successfully | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_update(user)
    msg = "User: UPDATE | User with ID #{user.id} " \
          "(username: #{user.username}) updated successfully | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_validation_error(action, errors)
    err_msg = "User: #{action.upcase} | User with Email #{params[:email]} " \
              "(username: #{params[:username]}) " \
              "#{action == 'create' ? 'creation' : 'update'} " \
              "failed due to validation errors:\n"
    errors.each { |e| err_msg << "- #{e}\n" }
    err_msg << '(400 Bad Request)'
    logger.warn(with_cid(err_msg))
  end

  def log_delete(user)
    msg = "User: DELETE | User with ID #{user.id} " \
          "(username: #{user.username}) deleted succesfully | (204 No Content)"
    logger.info(with_cid(msg))
  end

  def log_create(user)
    msg = "User: CREATE | User with Email #{user.email} " \
          "(username: #{user.username}) created successfully | (201 Created)"
    logger.info(with_cid(msg))
  end

  def log_login_post(error = nil)
    login_status = error ? 'failed' : 'successful'
    status_code = error ? '401 Unauthorized' : '200 OK'
    msg = "Session: LOGIN_POST | Login attempt for user #{params[:username]} " \
          "from IP address #{request.ip} #{error} " \
          "(#{login_status}) | (#{status_code})"
    error ? logger.warn(with_cid(msg)) : logger.info(with_cid(msg))
  end

  def log_login
    msg = 'Session: LOGIN_GET | Login form requested ' \
          "from IP address #{request.ip} | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_logout
    msg = "Session: LOGOUT | User '#{current_user.username}' " \
          "(session ID: #{session[:user_id]}) " \
          'logged out successfully | (200 OK)'
    logger.info(with_cid(msg))
  end

  def log_signup
    msg = "Signup form requested from IP address #{request.ip} " \
          "(user agent: #{request.user_agent}) | (200 OK)"
    logger.info(with_cid(msg))
  end
end
