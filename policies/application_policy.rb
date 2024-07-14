# frozen_string_literal: true

# Base policy class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @record = record
    @user = user
  end

  def authorize(action)
    allowed_to?(action)
  end

  def allowed_to?(action)
    public_send(action)
  end
end
