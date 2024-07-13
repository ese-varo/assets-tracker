# frozen_string_literal: true

require_relative 'application_policy'

class UserPolicy < ApplicationPolicy
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
    user.is_manager? || user.is_admin? && user.id != record.id
  end
end
