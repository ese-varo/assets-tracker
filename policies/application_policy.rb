# frozen_string_literal: true

class UnauthorizedAction < StandardError
  # TODO handle 401 renponse code
end

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @record = record
    @user = user
  end

  def authorize(action)
    return if allowed_to?(action)

    raise UnauthorizedAction, 'Unauthorized action'
  end

  def allowed_to?(action)
    public_send(action)
  end
end
