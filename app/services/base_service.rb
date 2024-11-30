# frozen_string_literal: true

# Base class for services
# It adds a call class method to handle execution of the process
# in charge of the service instance class.
class BaseService
  def self.call(*)
    new(*).call
  end

  private

  def success(data = nil)
    result(success?: true, data: data, error: nil)
  end

  def failure(error)
    result(success?: false, data: nil, error: error)
  end

  def result(**)
    base_struct = Struct.new(:success?, :data, :error, keyword_init: true)
    base_struct.new(**)
  end
end
