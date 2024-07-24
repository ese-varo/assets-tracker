# frozen_string_literal: true

module Exceptions
  class UnauthorizedAction < StandardError
    attr_accessor :log_message
    attr_reader :action, :record, :user

    def initialize(action, record, user)
      @record = record
      @action = action
      @user = user
      set_log_message
      super(public_error_message)
    end

    private

    def public_error_message
      "You are not authorized to #{action_to_text}"
    end

    def action_to_text
      raise NotImplementedError
    end

    def set_log_message
      @log_message = action == :index? ? log_list_message : log_common_message
    end

    def log_common_message
      "User: UNAUTHORIZED | Action: #{action_string} attempted " \
        "on #{record.class} with ID #{record.id} " \
        "by User with ID #{user.id} and Role #{user.role_as_string} " \
        "(username: #{user.username}) | (401 Unauthorized)"
    end

    def log_list_message
      raise NotImplementedError
    end

    def action_string
      action[..-2].capitalize
    end
  end

  class UnauthorizedUserAction < UnauthorizedAction
    private

    def action_to_text
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

    def log_list_message
      'User: UNAUTHORIZED | Access Users list attempted ' \
        "by User with ID #{user.id} with Role #{user.role_as_string} " \
        "(username: #{user.username}) | (401 Unauthorized)"
    end
  end

  class UnauthorizedAssetAction < UnauthorizedAction
    private

    def action_to_text
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

    def log_list_message
      'User: UNAUTHORIZED | Access Assets list attempted ' \
        "by User with ID #{user.id} with Role #{user.role_as_string} " \
        "(username: #{user.username}) | (401 Unauthorized)"
    end
  end
end
