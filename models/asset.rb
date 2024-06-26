# frozen_string_literal: true

# Handle interaction with database and model functionality
class Asset
  class << self
    def find_by_user_id(user_id)
      DB.execute(
        'SELECT * FROM assets WHERE user_id = ?', user_id
      )
    end

    def find(id, user_id)
      DB.get_first_row(
        'SELECT * FROM assets WHERE id = ? AND user_id = ?',
        [id, user_id]
      )
    end

    def create!(type, serial_number, user_id)
      query = <<-SQL
        INSERT INTO assets (type, serial_number, user_id)
        VALUES (?, ?, ?)
      SQL
      DB.execute query, [type.capitalize, serial_number.upcase, user_id]
    end

    def delete(id, user_id)
      DB.execute(
        'DELETE FROM assets WHERE id = ? AND user_id = ?',
        [id, user_id]
      )
    end

    def update(id:, type:, serial_number:, user_id:)
      stmt = DB.prepare <<-SQL
        UPDATE assets
        SET
          type = ?,
          serial_number = ?,
          updated_at = (unixepoch('now', 'localtime'))
        WHERE id = ?
        AND user_id = ?
      SQL
      stmt.execute type, serial_number, id, user_id
    end
  end
end
