# frozen_string_literal: true

# Handle interaction with database and model functionality
class Asset < Model::Base
  attr_reader :id, :updated_at, :created_at, :type,
              :serial_number, :user_id, :available

  TYPE_FORMAT_REGEX = /^(?!-)[a-zA-Z]+(-[a-zA-Z]+)*$/
  SERIAL_NUMBER_FORMAT_REGEX = /^[a-zA-Z0-9]+$/

  def initialize(
    type:, serial_number:, user_id:,
    id: nil, updated_at: nil, created_at: nil, available: nil
  )
    @id = id
    @updated_at = updated_at
    @created_at = created_at
    self.type = type
    self.serial_number = serial_number
    @user_id = user_id
    @available = available
    @errors = []
  end

  def type=(value)
    @type = value.capitalize
  end

  def serial_number=(value)
    @serial_number = value.upcase
  end

  def validate
    validate_type
    validate_serial_number
    @errors.empty?
  end

  def save!
    handle_asset_validation(save_err)
    DB.execute insert_query, [type, serial_number, user_id]
  rescue SQLite3::ConstraintException => e
    handle_constraint_exception(e)
  rescue SQLite3::Exception => e
    handle_generic_exceptions(e, save_err)
  end

  def update(type:, serial_number:)
    self.type = type
    self.serial_number = serial_number
    handle_asset_validation(update_err)

    stmt = DB.prepare update_query
    stmt.execute self.type, self.serial_number, id
  rescue SQLite3::Exception => e
    handle_generic_exception(e, update_err)
  end

  def request_by(user_id)
    raise Exceptions::AssetRequestError, asset_req_err_msg unless self.user_id.nil?

    DB.execute request_query, [user_id, self.id]
  rescue SQLite3::Exception => e
    handle_generic_exceptions(e, update_err)
  end

  private

  def handle_asset_validation(generic_err_msg)
    raise Exceptions::AssetValidationError.new(@errors, generic_err_msg) unless validate
  end

  def handle_generic_exceptions(error, generic_err_msg)
    @errors << error.message
    raise Exceptions::AssetValidationError.new(@errors, generic_err_msg)
  end

  def handle_constraint_exception(error)
    @errors << if match_unique_constraint_msg? error.message
                 unique_constraint_err_msg
               else
                 error.message
               end
    raise Exceptions::AssetValidationError.new(@errors, save_err)
  end

  def match_unique_constraint_msg?(message)
    message.match?(/UNIQUE.*serial_number/)
  end

  def insert_query
    <<-SQL
      INSERT INTO assets (type, serial_number, user_id)
      VALUES (?, ?, ?);
    SQL
  end

  def update_query
    <<-SQL
      UPDATE assets
      SET
        type = ?,
        serial_number = ?,
        updated_at = (unixepoch('now', 'localtime'))
      WHERE id = ?;
    SQL
  end

  def request_query
    <<-SQL
      INSERT INTO asset_requests (user_id, asset_id)
      VALUES (?, ?);
    SQL
  end

  def asset_req_err_msg
    'This asset cannot be requested, it is already assigned to another employee'
  end

  def unique_constraint_err_msg
    'Serial number should be unique, ' \
      "an asset with serial number #{serial_number} already exists"
  end

  def validate_type
    return if type.match? TYPE_FORMAT_REGEX

    @errors << 'Type can only contain letters and hyphens'
  end

  def validate_serial_number
    return if serial_number.match? SERIAL_NUMBER_FORMAT_REGEX

    @errors << 'Serial number can only contain letters and numbers'
  end

  class << self
    def create(**)
      asset = new(**)
      asset.save!
      asset
    end

    def requested_by_user(user_id)
      build_from_hash_collection(
        DB.execute(select_requested_by_user_query, user_id)
      )
    end

    def respond_to_missing?(name, include_private = false)
      /^find_by_(?<prop>.*)/ =~ name
      find_by_methods.include?(prop) || super
    end

    def table_name
      'assets'
    end

    private

    def find_by_methods
      %w[serial_number user_id]
    end

    def select_requested_by_user_query
      <<-SQL
      SELECT
        a.id,
        a.serial_number,
        a.type,
        a.user_id,
        a.available,
        a.created_at,
        a.updated_at
      FROM
        asset_requests ar
      INNER JOIN
        assets a
      ON
        a.id = ar.asset_id
      INNER JOIN
        users u
      ON
        u.id = ar.user_id
      WHERE ar.user_id = ?;
      SQL
    end
  end
end
