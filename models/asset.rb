# frozen_string_literal: true

require_relative 'model'

class AssetValidationError < ValidationError; end

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
    raise AssetValidationError.new(@errors, save_err) unless validate

    query = <<-SQL
      INSERT INTO assets (type, serial_number, user_id)
      VALUES (?, ?, ?)
    SQL
    DB.execute query, [type, serial_number, user_id]
  rescue SQLite3::Exception => e
    @errors << e.message
    raise AssetValidationError.new(@errors, save_err)
  end

  def update(type:, serial_number:)
    self.type = type
    self.serial_number = serial_number
    raise AssetValidationError.new(@errors, update_err) unless validate

    stmt = DB.prepare <<-SQL
      UPDATE assets
      SET
        type = ?,
        serial_number = ?,
        updated_at = (unixepoch('now', 'localtime'))
      WHERE id = ?
    SQL
    stmt.execute type, serial_number, id
  rescue SQLite3::Exception => e
    @errors << e.message
    raise AssetValidationError.new(@errors, update_err)
  end

  private

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

    def respond_to_missing?(name, include_private = false)
      /^find_by_(?<prop>.*)/ =~ name
      find_by_methods.include?(prop) || super
    end

    private

    def find_by_methods
      %w[serial_number user_id]
    end

    def table_name
      'assets'
    end
  end
end
