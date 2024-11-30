# frozen_string_literal: true

# policy to handle authorization on the user resource
class UserPolicy < ApplicationPolicy
  def authorize(action)
    return if super

    raise UnauthorizedUserAction.new(action, record, user)
  end

  def index?
    user.is_manager? || user.is_admin?
  end

  def show?
    user.is_manager? || user.is_admin? || user.id == record.id
  end

  def update?
    user.is_manager? || user.is_admin? || user.id == record.id
  end

  def change_role?
    (user.is_manager? || user.is_admin?) && user.id != record.id
  end

  def destroy?
    (user.is_manager? || user.is_admin?) && user.id != record.id
  end
end
