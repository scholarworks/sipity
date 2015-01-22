module Sipity
  module Decorators
    # Responsible for exposing an interface to register a set and item as well
    # as iterate on those concerns.
    #
    # TODO: Should the set container be a named object
    class TodoList
      def initialize(options = {})
        @entity = options.fetch(:entity)
        # REVIEW: Should I be including this? Or is it up to the initializer of
        #   this object?
        @item_builder = options.fetch(:item_builder) { default_item_builder }
        @sets = {}
        yield(self) if block_given?
      end

      attr_reader :entity, :sets
      attr_reader :item_builder
      private :item_builder

      def add_to(set:, name:, state:)
        sets[set.to_s] ||= Set.new
        sets[set.to_s] << item_builder.call(name, state)
      end

      private

      def default_item_builder
        lambda do |name, state|
          EntityEnrichmentAction.new(entity: entity, name: name, state: state)
        end
      end
    end
  end
end
