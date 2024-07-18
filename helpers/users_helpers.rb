# frozen_string_literal: true

# User only helpers
module UsersHelpers
  def valid_password?(password_hash, password)
    BCrypt::Password.new(password_hash) == password
  end

  def public_paths
    %w[/login /signup /logout]
  end
end
