# frozen_string_literal: true

module Exceptions
  class UnauthorizedAction < StandardError
    def initialize(action)
      super(error_message(action))
    end

    private

    def error_message(action)
      "You are not authorized to #{action_to_text(action)}"
    end

    def action_to_text(_action)
      raise NotImplementedError
    end
  end

  class UnauthorizedUserAction < UnauthorizedAction
    private

    def action_to_text(action)
      case action
      when :show?, :index?
        'access this page'
      when :update?
        'update this user'
      when :destroy?
        'delete this user'
      else
        'execute this action'
      end
    end
  end

  class UnauthorizedAssetAction < UnauthorizedAction
    private

    def action_to_text(action)
      case action
      when :show?, :index?
        'access this page'
      when :update?
        'update this asset'
      when :destroy?
        'delete this asset'
      when :new?, :create?
        'create an asset'
      else
        'execute this action'
      end
    end
  end
end
