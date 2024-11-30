# frozen_string_literal: true

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
    @log_message = case action
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

  ACTION_PHRASES = {
    show?: 'access this page',
    index?: 'access this page',
    update?: 'update this asset',
    destroy?: 'delete this asset',
    new?: 'create an asset',
    create?: 'create an asset',
    upload_csv?: 'upload assets from csv',
    show_upload_csv?: 'upload assets from csv',
    show_pending_requests?: 'manage asset requests',
    request?: 'request asset',
    reject?: 'reject asset request',
    remove_request?: 'remove asset request'
  }.freeze

  CUSTOM_ACTION_LOG_METHODS = {
    show_upload_csv?: :log_show_upload_csv,
    show_pending_requests?: :log_show_pending_requests,
    upload_csv?: :log_upload_csv,
    request?: :log_common,
    reject?: -> { log_asset_request('Reject') },
    remove_request?: -> { log_asset_request('Remove') }
  }.freeze

  def action_phrase
    ACTION_PHRASES.fetch(action, 'execute this action')
  end

  def set_log_message
    return super unless custom_actions.include? action

    log_method = CUSTOM_ACTION_LOG_METHODS[action]
    log_method.is_a?(Proc) ? log_method.call : send(log_method)
  end

  def custom_actions
    %i[
      show_upload_csv?
      upload_csv?
      request?
      show_pending_requests?
      reject?
      remove_request
    ]
  end

  def log_new
    "#{log_base_message} | Access to Assets new form attempted"
  end

  def log_index
    "#{log_base_message} | Access to Assets list attempted"
  end

  def log_show_upload_csv
    "#{log_base_message} | Access to Assets upload csv form attempted"
  end

  def log_show_pending_requests
    "#{log_base_message} | Access to Assets pending requests attempted"
  end

  def log_asset_request(action)
    "#{log_base_message} | Action: #{action} Asset Request attempted"
  end

  def log_upload_csv
    "#{log_base_message} | Action: #{action_string} attempted on Assets"
  end
end
