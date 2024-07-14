# frozen_string_literal: true

# Module to handle authentication functionality
module Authentication
  def authenticate!
    return if authenticated?

    # halt 401, 'Not authorized'
    session[:original_request] = request.path
    redirect '/login'
  end

  # Depending on the controller action where this method
  # might be called the syntax would vary. There are two scenarios:
  # 1. Actions where the resource already exist and can be
  #    instanciated prior authorization, e.g. to update an asset
  #    the method call would be: authorize! @asset, to: update?
  # 2. Actions where there like index? or new? where the porpouse
  #    is to verify the authorization to show that view
  #    e.g. assets show index view: authorize! to: index?, Asset
  #    e.g. assets show edit view:  authorize! to: update?, Asset
  def authorize!(record = nil, to:, on: nil)
    policy(record, on: on).authorize(to)
  end

  def allowed_to?(action, record)
    policy(record).allowed_to?(action)
  end

  private

  def authenticated?
    !!session[:user_id]
  end

  def policy(record, on: nil)
    resource_name = on || record.class
    klass = Kernel.const_get("#{resource_name}Policy")
    klass.new(current_user, record)
  end
end
