# frozen_string_literal: true

# Handles data fetching from db for assets with its associated records
class AssetDTO
  class << self
    def find_by_id(asset_id)
      db_results_as_array do
        asset_with_user_row = DB.get_first_row(asset_with_user_query, asset_id)
        build_asset_with_user(asset_with_user_row)
      end
    end

    def all
      db_results_as_array do
        assets_with_user = DB.execute(assets_with_user_query)
        assets_with_user.map { |row| build_asset_with_user(row) }
      end
    end

    private

    def db_results_as_array
      DB.results_as_hash = false
      result = yield
      DB.results_as_hash = true
      result
    end

    def build_asset_with_user(row)
      asset = build_asset(row[..6])
      asset.user = build_user(row[7..])
      asset
    end

    def build_asset(row)
      asset_data = {}
      Asset.column_names.each_with_index { |col, idx| asset_data[col] = row[idx] }
      Asset.new(**asset_data)
    end

    def build_user(row)
      return nil if row[0].nil?

      user_data = {}
      User.column_names.each_with_index { |col, idx| user_data[col] = row[idx] }
      User.new(**user_data)
    end

    def assets_with_user_query
      'SELECT a.*, u.* FROM assets a LEFT JOIN users u ON u.id = a.user_id;'
    end

    def asset_with_user_query
      <<-SQL
      SELECT a.*, u.* FROM assets a
      LEFT JOIN users u ON u.id = a.user_id
      WHERE a.id = ?;
      SQL
    end
  end
end
