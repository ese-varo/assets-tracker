# frozen_string_literal: true

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
        created_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime')),
        updated_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime'))
      );
      SQL
      @db.execute query
    end
  end
end
