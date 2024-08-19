# frozen_string_literal: true

# Logger Wrapper to handle adding the correlation id on logs
# related to the same request. It is usefull in places
# where the correlation_id env var can't be accessed, such as
# the case for the '/upload_csv' asset action where we need to log
# into the CSVAssetImporterService class
# the process for each asset imported from a csv file.
class LoggerWrapper
  def initialize(logger, correlation_id)
    @correlation_id = correlation_id
    @logger = logger
  end

  %i[unknown fatal error warn info debug].each do |level|
    define_method(level) do |msg|
      log(level, msg)
    end
  end

  private

  attr_reader :correlation_id, :logger

  def log(level, msg)
    logger.send(level, with_cid(msg))
  end

  def with_cid(msg)
    "\"correlation_id: #{correlation_id}\" -- : #{msg}"
  end
end
