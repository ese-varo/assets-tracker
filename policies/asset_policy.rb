# frozen_string_literal: true

require_relative 'application_policy'

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

