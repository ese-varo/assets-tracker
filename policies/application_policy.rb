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

class AssetPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.is_manager? || user.is_admin?
  end

  def destroy?
    user.is_manager? || user.is_admin?
  end
end

class UserPolicy < ApplicationPolicy
  def show?
    user.is_manager? || user.is_admin?
  end

  def update?
    user.is_manager? || user.is_admin?
  end

  def destroy?
    user.is_manager? || user.is_admin? && user.id != record.id
  end
end
