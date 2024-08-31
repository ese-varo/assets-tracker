# frozen_string_literal: true

# Handles data fetching from db for assets with its associated records
class AssetDTO
  AssetRequest = Struct.new(:asset_id, :user_id)

  class << self
    def find_by_id_with_user(asset_id)
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

    def find_request(asset_id, user_id)
      result = DB.get_first_row(find_request_query, [asset_id, user_id])
      return nil unless result

      AssetRequest.new(result['asset_id'], result['user_id'])
    end

    def pending_requests
      db_results_as_array do
        req_assets_with_user = DB.execute(req_assets_with_user_query, 'pending')
        req_assets_with_user.map { |row| build_asset_with_user(row) }
      end
    end

    def approve_asset_request(asset_id, user_id)
      DB.execute(update_asset_request_query, ['approved', asset_id, user_id])
    rescue SQLite3::Exception => e
      raise Exceptions::AssetRequestError, "Error while approving request: #{e.message}"
    end

    def reject_asset_request(asset_id, user_id)
      DB.execute(update_asset_request_query, ['rejected', asset_id, user_id])
    rescue SQLite3::Exception => e
      raise Exceptions::AssetRequestError, "Error while rejecting request: #{e.message}"
    end

    def remove_asset_request(asset_id, user_id)
      DB.execute(remove_asset_request_query, [asset_id, user_id])
    rescue SQLite3::Exception => e
      raise Exceptions::AssetRequestError, "Error while removing request: #{e.message}"
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
      user = build_user(row[7..])
      [asset, user]
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

    def req_assets_with_user_query
      <<-SQL
      SELECT
        a.*,
        u.*
      FROM
        asset_requests ar
      INNER JOIN
        assets a
      ON
        a.id = ar.asset_id
      INNER JOIN
        users u
      ON
        u.id = ar.user_id
      WHERE ar.status = ?;
      SQL
    end

    def update_asset_request_query
      <<-SQL
      UPDATE asset_requests
      SET status = ?
      WHERE asset_id = ? AND user_id = ?;
      SQL
    end

    def remove_asset_request_query
      'DELETE FROM asset_requests WHERE asset_id = ? AND user_id = ?;'
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

    def find_request_query
      'SELECT * FROM asset_requests WHERE asset_id = ? AND user_id = ?;'
    end
  end
end
