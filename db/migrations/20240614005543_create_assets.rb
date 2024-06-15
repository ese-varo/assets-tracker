module Migrations
  class CreateAssets < Migration
    def up
      query = <<-SQL
      CREATE TABLE assets (
        id            INTEGER PRIMARY KEY ASC,
        serial_number VARCHAR(80) NOT NULL,
        type          VARCHAR(80) NOT NULL,
        available     BOOLEAN DEFAULT 1,
        user_id       INTEGER REFERENCES users(id) ON DELETE NO ACTION,
        created_at    INTEGER NOT NULL DEFAULT (unixepoch()),
        updated_at    INTEGER NOT NULL DEFAULT (unixepoch())
      );
      SQL
      @db.execute query
    end

    def down
    end
  end
end
