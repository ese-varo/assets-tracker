# frozen_string_literal: true

module Migration
  class CreateUsers < Base
    def up
      query = <<-SQL
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY ASC,
        username      VARCHAR(80) UNIQUE NOT NULL,
        email         VARCHAR(80) UNIQUE NOT NULL,
        employee_id   VARCHAR(255) UNIQUE NOT NULL,
        role          INTEGER NOT NULL DEFAULT 0,
        password_hash VARCHAR(255) NOT NULL,
        created_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime')),
        updated_at    INTEGER NOT NULL DEFAULT (unixepoch('now', 'localtime'))
      );
      SQL
      db.execute query
    end
  end
end
