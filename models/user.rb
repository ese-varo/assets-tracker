# frozen_string_literal: true

require_relative 'model'

class UserValidationError < ValidationError; end

# Handle interaction with database and model functionality
class User < Model::Base
  attr_reader :id, :username, :email, :employee_id,
              :password_hash, :created_at, :updated_at

  USERNAME_FORMAT_REGEX = /^[a-zA-Z]+(?:_[a-zA-Z]+)*$/
  EMAIL_FORMAT_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  EMPLOYEE_ID_FORMAT_REGEX = /^[a-zA-Z0-9]+$/

  def initialize(
    username:, email:, employee_id:, id: nil,
    password_hash: nil, created_at: nil, updated_at: nil
  )
    @id = id
    @username = username
    @email = email
    self.employee_id = employee_id
    @password_hash = password_hash
    @created_at = created_at
    @updated_at = updated_at
    @errors = []
  end

  def employee_id=(value)
    @employee_id = value.upcase
  end

  def validate
    validate_username
    validate_email
    validate_employee_id
    @errors.empty?
  end

  def save!
    raise UserValidationError.new(@errors, save_err) unless validate

    query = <<-SQL
      INSERT INTO users (username, email, employee_id, password_hash)
      VALUES (?, ?, ?, ?)
    SQL
    DB.execute query, [
      username,
      email,
      employee_id,
      password_hash
    ]
  rescue SQLite3::Exception => e
    @errors << e.message
    raise UserValidationError.new(@errors, save_err)
  end

  private

  def validate_username
    return if username.match? USERNAME_FORMAT_REGEX

    @errors << 'Username can only contain letters and downscores in between'
  end

  def validate_email
    return if email.match? EMAIL_FORMAT_REGEX

    @errors << 'Not a valid format for email'
  end

  def validate_employee_id
    return if employee_id.match? EMPLOYEE_ID_FORMAT_REGEX

    @errors << 'Employee id can only contain letters and numbers'
  end

  class << self
    def create!(**params)
      data = params.except(:password)
      data[:password_hash] = hash_password(params[:password])
      user = new(**data)
      user.save!
      user
    end

    def hash_password(password)
      @password_hash = BCrypt::Password.create(password)
    end

    def respond_to_missing?(name, include_private = false)
      /^find_by_(?<prop>.*)/ =~ name
      find_by_methods.include?(prop) || super
    end

    private

    def find_by_methods
      %w[username email employee_id]
    end

    def table_name
      'users'
    end
  end
end
