# frozen_string_literal: true

class AssetValidationError < StandardError
  attr_reader :errors

  def initialize(errors, generic_message)
    super(generic_message)
    @errors = errors
  end
end

# Handle interaction with database and model functionality
class Asset
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
    self.type = type.capitalize
    self.serial_number = serial_number.upcase
    @user_id = user_id
    @available = available
    @validation_errors = []
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
    @validation_errors.empty?
  end

  def save!
    err_msg = 'Error on save'
    raise AssetValidationError.new(@validation_errors, err_msg) unless validate

    query = <<-SQL
      INSERT INTO assets (type, serial_number, user_id)
      VALUES (?, ?, ?)
    SQL
    DB.execute query, [type, serial_number, user_id]
  rescue SQLite3::Exception => e
    @validation_errors << e.message
    raise AssetValidationError.new(@validation_errors, err_msg)
  end

  def update(type:, serial_number:)
    err_msg = 'Error on update'
    self.type = type
    self.serial_number = serial_number
    raise AssetValidationError.new(@validation_errors, err_msg) unless validate

    stmt = DB.prepare <<-SQL
      UPDATE assets
      SET
        type = ?,
        serial_number = ?,
        updated_at = (unixepoch('now', 'localtime'))
      WHERE id = ?
      AND user_id = ?
    SQL
    stmt.execute type, serial_number, id, user_id
  rescue SQLite3::Exception => e
    @validation_errors << e.message
    raise AssetValidationError.new(@validation_errors, err_msg)
  end

  private

  def validate_type
    return if type.match? TYPE_FORMAT_REGEX

    @validation_errors << 'Type can only contain letters and hyphens'
  end

  def validate_serial_number
    return if serial_number.match? SERIAL_NUMBER_FORMAT_REGEX

    @validation_errors << 'Serial number can only contain letters and numbers'
  end

  class << self
    def create(**)
      asset = new(**)
      asset.save!
      asset
    end

    def find_by_user_id(user_id)
      DB.execute(
        'SELECT * FROM assets WHERE user_id = ?', user_id
      )
    end

    def find(id, user_id)
      asset = DB.get_first_row(
        'SELECT * FROM assets WHERE id = ? AND user_id = ?',
        [id, user_id]
      )
      new(**asset.transform_keys(&:to_sym))
    end

    def delete(id, user_id)
      DB.execute(
        'DELETE FROM assets WHERE id = ? AND user_id = ?',
        [id, user_id]
      )
    end
  end
end
