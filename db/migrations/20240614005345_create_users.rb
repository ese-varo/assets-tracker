module Migrations
  class CreateUsers < Migration
    def up
      query = <<-SQL
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY ASC,
        username      VARCHAR(80) UNIQUE NOT NULL,
        email         VARCHAR(80) UNIQUE NOT NULL,
        employee_id   VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL
      );
      SQL
      @db.execute query
    end

    def down
    end
  end
end
