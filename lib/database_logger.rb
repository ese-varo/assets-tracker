# frozen_string_literal: true

require 'logger'

module Database
  # custom logger for database
  class CustomLogger
    attr_reader :logger

    def initialize
      @logger = Logger.new(STDOUT)
      default_format_setup
    end

    private

    def default_format_setup
      @logger.formatter = proc do |severity, _datetime, _progname, msg|
        "#{severity} - #{msg}\n"
      end
    end
  end
end
