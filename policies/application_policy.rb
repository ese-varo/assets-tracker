# frozen_string_literal: true

# Base policy class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @record = record
    @user = user
  end

  def authorize(action)
    return if allowed_to?(action)

    raise Exceptions::UnauthorizedAction, action
  end

  def allowed_to?(action)
    public_send(action)
  end
end
