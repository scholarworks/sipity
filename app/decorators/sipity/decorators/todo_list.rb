module Sipity
  module Decorators
    class TodoList
      def initialize(options = {})
        @entity = options.fetch(:entity)
        @item_builder = options.fetch(:item_builder) { default_item_builder }
        @item_sets = {}
      end

      attr_reader :entity, :item_sets
      attr_reader :item_builder
      private :item_builder

      def add_to(item_set:, item_name:)
        item_sets[item_set.to_s] ||= Set.new
        item_sets[item_set.to_s] << item_builder.call(item_name)
      end

      private

      def default_item_builder
        lambda do |name|
          EntityEnrichmentAction.new(entity: entity, name: name)
        end
      end
    end
  end
end
