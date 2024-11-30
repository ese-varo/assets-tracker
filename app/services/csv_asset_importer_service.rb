# frozen_string_literal: true

require 'csv'

# Handle the process to import assets from a csv file.
# Existing assets are going to be updated, non existent
# are going to be createded.
class CSVAssetImporterService < BaseService
  attr_reader :logger

  def initialize(csv_file, db, logger)
    @db = db
    @csv_file = csv_file
    @logger = logger
    @created_assets = 0
    @updated_assets = Hash.new(0)
  end

  def call
    validate_csv
    import_assets
    logger.info(success_msg)
    success(success_msg)
  rescue CSVFileError => e
    err_msg = "Error on CSV file validation: #{e.message}"
    logger.error(err_msg)
    failure(err_msg)
  end

  private

  attr_reader :csv_file, :db
  attr_accessor :created_assets, :updated_assets

  def import_assets
    table = CSV.read(csv_file, headers: true)
    logger.info('Asset: UPDATE-CREATE | Import from CSV process initiated')
    table.each { |row| process_asset(build_asset_from_row(row)) }
  end

  def validate_csv
    CSVFileValidator.validate(csv_file, asset_safe_params)
  end

  def process_asset(asset_data)
    asset = Asset.find_by_serial_number(asset_data[:serial_number].upcase)
    db.transaction do
      if asset
        process_asset_update(asset, asset_data)
      else
        process_asset_creation(asset_data)
      end
    end
  end

  def process_asset_creation(asset_data)
    new_asset = Asset.create(**asset_data)
    self.created_assets += 1
    log_create(new_asset)
  end

  def process_asset_update(asset, new_asset_data)
    asset.update(**new_asset_data.slice(:serial_number, :type))
    updated_assets[asset.id] += 1
    log_update(asset)
  end

  def log_update(asset)
    msg = "Asset: UPDATE | Asset imported from CSV with ID #{asset.id} " \
          'updated successfully | (200 OK)'
    logger.info(msg)
  end

  def log_create(asset)
    msg = "Asset: CREATE | Asset imported from CSV with ID #{asset.id} " \
          'created successfully | (201 Created)'
    logger.info(msg)
  end

  def build_asset_from_row(row)
    raise CSVFileError, 'Invalid CSV Format' unless valid_row_format?(row)

    asset_data = {}
    row.each do |column|
      key = column[0].to_sym
      next unless asset_safe_params.include? key

      asset_data[key] = column[1]
    end
    asset_data
  end

  def include_required_fields?(row)
    asset_safe_params.each do |param|
      return false unless row.include?(param.to_s)
    end
    true
  end

  def valid_row_format?(row)
    include_required_fields?(row) && valid_column_count?(row)
  end

  def valid_column_count?(row)
    row.size == asset_safe_params.size
  end

  def success_msg
    "Assets successfully imported from CSV file:\n" \
      "- Created Assets: #{created_assets}\n" \
      "- Updated Assets: #{updated_assets.size}"
  end

  def asset_safe_params
    %i[serial_number type user_id]
  end
end
