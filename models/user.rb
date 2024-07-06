# frozen_string_literal: true

require_relative 'base'

# Handle interaction with database and model functionality
class User < Base
  attr_reader :id, :username, :email, :employee_id,
              :password_hash, :created_at, :updated_at
  def initialize(
    id:, username:, email:, employee_id:,
    password_hash:, created_at:, updated_at:
  )
    @id = id
    @username = username
    @email = email
    @employee_id = employee_id
    @password_hash = password_hash
    @created_at = created_at
    @updated_at = updated_at
  end

  class << self
    def create(username:, email:, employee_id:, password:)
      query = <<-SQL
        INSERT INTO users (username, email, employee_id, password_hash)
        VALUES (?, ?, ?, ?)
      SQL
      DB.execute query, [
        username,
        email,
        employee_id,
        hash_password(password)
      ]
    end

    def hash_password(password)
      BCrypt::Password.create(password)
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
