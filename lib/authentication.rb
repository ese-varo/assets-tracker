# frozen_string_literal: true

# load policies
Dir[File.join(__dir__, '..', 'policies', '*.rb')].each {|file| require file}

# Module to handle authentication functionality
module Authentication
  def authenticate!
    return if authenticated?

    # halt 401, 'Not authorized'
    session[:original_request] = request.path
    redirect '/login'
  end

  def authorize!(record, to:)
    policy(record).authorize(to)
  end

  def allowed_to?(action, record)
    authorize!(record, to: action)
  end

  private

  def authenticated?
    !!session[:user_id]
  end

  def policy(record)
    policy_class = Kernel.const_get("#{record.class}Policy")
    policy_class.new(current_user, record)
  end
end
