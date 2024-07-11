# frozen_string_literal: true

module Migration
  # New migration classes inherit from this class
  class Base
    attr_reader :db

    def initialize(db)
      @db = db
    end

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end
