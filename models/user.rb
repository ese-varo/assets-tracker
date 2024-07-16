# frozen_string_literal: true

# Handle interaction with database and model functionality
class User < Model::Base
  attr_accessor :username, :email, :role
  attr_reader :id, :employee_id, :password_hash, :created_at, :updated_at

  ROLE = { employee: 0, manager: 1, admin: 2 }.freeze
  USERNAME_FORMAT_REGEX = /^[a-zA-Z]+(?:_[a-zA-Z]+)*$/
  EMAIL_FORMAT_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  EMPLOYEE_ID_FORMAT_REGEX = /^[a-zA-Z0-9]+$/

  def initialize(
    username:, email:, employee_id:, role: nil, id: nil,
    password_hash: nil, created_at: nil, updated_at: nil
  )
    @id = id
    @username = username
    @email = email
    self.employee_id = employee_id
    @role = role
    @password_hash = password_hash
    @created_at = created_at
    @updated_at = updated_at
    @errors = []

    define_role_methods
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
    raise Exceptions::UserValidationError.new(@errors, save_err) unless validate

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
    raise Exceptions::UserValidationError.new(@errors, save_err)
  end

  def update(username:, email:, employee_id:, role:)
    self.username = username
    self.email = email
    self.employee_id = employee_id
    self.role = role
    raise Exceptions::UserValidationError.new(@errors, update_err) unless validate

    stmt = DB.prepare <<-SQL
      UPDATE users
      SET
        username = ?,
        email = ?,
        employee_id = ?,
        role = ?,
        updated_at = (unixepoch('now', 'localtime'))
      WHERE id = ?
    SQL
    stmt.execute username, email, employee_id, role, id
  rescue SQLite3::Exception => e
    @errors << e.message
    raise Exceptions::UserValidationError.new(@errors, update_err)
  end

  def define_role_methods
    ROLE.each_key do |key|
      User.define_method(:"is_#{key}?") do
        role == ROLE[key]
      end
    end
  end

  def role_as_string
    ROLE.key(role).capitalize
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

    def table_name
      'users'
    end

    private

    def find_by_methods
      %w[username email employee_id]
    end
  end
end
