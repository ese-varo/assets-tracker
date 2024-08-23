# frozen_string_literal: true

# policy to handle authorization on the asset resource
class AssetPolicy < ApplicationPolicy
  def authorize(action)
    return if super

    raise Exceptions::UnauthorizedAssetAction.new(action, record, user)
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?
    user.is_manager? || user.is_admin?
  end

  def show_upload_csv?
    user.is_manager? || user.is_admin?
  end

  def upload_csv?
    user.is_manager? || user.is_admin?
  end

  def request?
    true
  end

  def unassign?
    user.is_manager? || user.is_admin?
  end

  def create?
    user.is_manager? || user.is_admin?
  end

  def update?
    user.is_manager? || user.is_admin?
  end

  def destroy?
    user.is_manager? || user.is_admin?
  end
end
