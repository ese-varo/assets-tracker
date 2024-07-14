# frozen_string_literal: true

module Model
  # Handle common functionlaity for models
  class Base
    def destroy(id)
      DB.execute("DELETE FROM #{table_name} WHERE id = ?", id)
    end

    private

    def save_err
      "Error while saving #{self.class}"
    end

    def update_err
      "Error while updating #{self.class}"
    end

    class << self
      def all
        build_from_hash_collection(DB.execute "SELECT * FROM #{table_name}")
      end

      def method_missing(name, *params, **key_params)
        if /^find_by_(?<prop>.*)/ =~ name
          find_by(prop, *params, **key_params)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        name.to_s == 'find_by_id' || super
      end

      private

      def arg_err_msg(prop)
        "Missing arguments: #{prop} value is required"
      end

      def no_method_msg(prop)
        "undefined method `find_by_#{prop}` for class #{self}"
      end

      def valid_find_by_method?(prop)
        respond_to?("find_by_#{prop}")
      end

      def find_by(prop, *params, as_collection: false)
        raise NoMethodError, no_method_msg(prop) unless valid_find_by_method?(prop)

        value = params[0]
        raise ArgumentError, arg_err_msg(prop.to_s) if value.nil?

        if as_collection
          build_from_hash_collection(DB.execute(select_all_query(prop), value))
        else
          build_from_hash(DB.get_first_row(select_all_query(prop), value))
        end
      end

      def select_all_query(prop)
        "SELECT * FROM #{table_name} WHERE #{prop} = ?"
      end

      def find_by_methods
        raise NotImplementedError
      end

      def table_name
        raise NotImplementedError
      end

      def build_from_hash(hash)
        return unless hash

        new(**hash.transform_keys(&:to_sym))
      end

      def build_from_hash_collection(hash_collection)
        return unless hash_collection

        hash_collection.map { |elem| build_from_hash(elem) }
      end
    end
  end
end
