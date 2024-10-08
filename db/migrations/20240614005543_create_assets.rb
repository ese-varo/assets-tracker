# frozen_string_literal: true

module Migration
  class CreateAssets < Base
    def up
      query = <<-SQL
      CREATE TABLE assets (
        id            INTEGER PRIMARY KEY ASC,
        serial_number VARCHAR(80) UNIQUE COLLATE NOCASE NOT NULL,
        type          VARCHAR(80) NOT NULL,
        user_id       INTEGER REFERENCES users(id) ON DELETE NO ACTION,
        created_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime')),
        updated_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime')),
        available     BOOLEAN AS (user_id IS NOT NULL) VIRTUAL
      );
      SQL
      db.execute query
    end
  end
end
