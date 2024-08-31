# frozen_string_literal: true

module Migration
  class CreateAssetRequests < Base
    def up
      query = <<-SQL
      CREATE TABLE asset_requests (
        user_id INTEGER REFERENCES users(id) ON DELETE NO ACTION,
        asset_id INTEGER REFERENCES assets(id) ON DELETE NO ACTION,
        status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
        CONSTRAINT asset_requests_pk PRIMARY KEY (user_id, asset_id)
      );
      SQL
      db.execute query
    end
  end
end
