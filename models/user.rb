# frozen_string_literal: true

# Handle interaction with database and model functionality
class User
  class << self
    def find_by_username(username)
      query = 'SELECT * FROM users WHERE username = ?'
      DB.get_first_row query, username
    end

    def find(id)
      query = 'SELECT * FROM users WHERE id = ?'
      DB.get_first_row query, id
    end

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
  end
end
