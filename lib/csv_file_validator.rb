# frozen_string_literal: true

# Validates csv files
class CSVFileValidator
  class << self
    def validate(file, required_headers)
      raise CSVFileError, 'No file uploaded' if file.nil?
      raise CSVFileError, 'File is empty' if file.read.empty?

      handle_missing_headers(file, required_headers)
      CSV.parse(File.read(file), skip_blanks: true, strip: true)
    rescue CSV::MalformedCSVError => e
      raise CSVFileError, "Invalid CSV format: #{e.message}"
    end

    private

    def handle_missing_headers(file, required_headers)
      csv = CSV.read(file, headers: true)
      headers = csv.headers
      missing_headers = required_headers.map(&:to_s) - headers
      err_msg = "Missing required headers: #{missing_headers.join(', ')}"

      raise CSVFileError, err_msg if missing_headers.any?
    end
  end
end
