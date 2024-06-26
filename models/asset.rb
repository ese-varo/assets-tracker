# frozen_string_literal: true

# Handle interaction with database and model functionality
class Asset
  class << self
    def all
      DB.execute('SELECT * FROM assets')
    end

    def find(id)
      DB.get_first_row('SELECT * FROM assets WHERE id = ?', id)
    end

    def create(type, serial_number)
      query = <<-SQL
        INSERT INTO assets (type, serial_number)
        VALUES (?, ?)
      SQL
      DB.execute query, [type.capitalize, serial_number.upcase]
    end

    def delete(id)
      DB.execute 'DELETE FROM assets WHERE id = ?', id
    end

    def update(id:, type:, serial_number:)
      stmt = DB.prepare <<-SQL
        UPDATE assets
        SET
          type = ?,
          serial_number = ?,
          updated_at = (unixepoch('now', 'localtime'))
        WHERE id = ?
      SQL
      stmt.execute type, serial_number, id
    end
  end
end
