# frozen_string_literal: true

require_relative 'application_policy'

class AssetPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    user.is_manager? || user.is_admin?
  end

  def create?
    user.is_manager? || user.i_admin?
  end

  def update?
    user.is_manager? || user.is_admin?
  end

  def destroy?
    user.is_manager? || user.is_admin?
  end
end

