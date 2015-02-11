module Sipity
  module Decorators
    # Container for interacting and defining Actions.
    module Actions
      ANALOGOUS_RESOURCEFUL_ACTION_NAMES = {
        'show' => ['show'],
        'update' => ['edit', 'update'],
        'edit' => ['edit', 'update'],
        'create' => ['new', 'create'],
        'new' => ['new', 'create'],
        'destroy' => ['destroy']
      }.freeze

      RESOURCEFUL_ACTION_NAMES = ANALOGOUS_RESOURCEFUL_ACTION_NAMES.freeze

      module_function

      def action_names_without_current_action_and_analogies(action_names:, current_action_name:)
        Array.wrap(action_names).map(&:to_s) - Array.wrap(ANALOGOUS_RESOURCEFUL_ACTION_NAMES[current_action_name.to_s])
      end

      def builder_for_action_name(action_name)
        if RESOURCEFUL_ACTION_NAMES.include?(action_name.to_s)
          ResourcefulAction
        else
          StateAdvancingAction
        end
      end

      def build(options = {})
        builder_for_action_name(options.fetch(:name)).new(options)
      end
    end
  end
end
