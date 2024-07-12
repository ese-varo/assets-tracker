# frozen_string_literal: true

require_relative 'application_policy'

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
