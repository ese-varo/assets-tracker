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
      "You are not authorized to #{action_phrase}"
    end

    def action_phrase
      raise NotImplementedError
    end

    def set_log_message
      @log_message = case(action)
                     when :index? then log_index
                     when :new? then log_new
                     when :update?, :show?, :create?, :destroy?
                       log_common
                     end
    end

    def log_base_message
      "User: UNAUTHORIZED | User ID: #{user.id}, " \
        "Role: #{user.role_as_string}, " \
        "Username: #{user.username} | (401 Unauthorized)"
    end

    def log_common
      "#{log_base_message} | Action: #{action_string} attempted " \
        "on #{record.class} with ID #{record.id}"
    end

    def log_index
      raise NotImplementedError
    end

    def action_string
      action[..-2].capitalize
    end
  end

  class UnauthorizedUserAction < UnauthorizedAction
    private

    def action_phrase
      case action
      when :show?, :index? then 'access this page'
      when :update? then 'update this user'
      when :destroy? then 'delete this user'
      else 'execute this action'
      end
    end

    def log_index
      "#{log_base_message} | Access Users list attempeted"
    end
  end

  class UnauthorizedAssetAction < UnauthorizedAction
    private

    def action_phrase
      case action
      when :show?, :index? then 'access this page'
      when :update? then 'update this asset'
      when :destroy? then 'delete this asset'
      when :new?, :create? then 'create an asset'
      else 'execute this action'
      end
    end

    def set_log_message
      if custom_actions.include? action
        case action
        when :show_load_csv? then log_show_load_csv
        when :load_csv? then log_load_csv
        end
      else
        super
      end
    end

    def custom_actions
      [:show_load_csv?, :load_csv?]
    end

    def log_new
      "#{log_base_message} | Access Assets new form attempted"
    end

    def log_index
      "#{log_base_message} | Access Assets list attempted"
    end

    def log_show_load_csv
      "#{log_base_message} | Access Assets load csv form attempted"
    end

    def log_load_csv
      "#{log_base_message} | Action: #{action_string} attempted on Assets"
    end
  end
end
