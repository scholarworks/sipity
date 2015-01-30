module Sipity
  module Decorators
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
        Array.wrap(action_names) - Array.wrap(ANALOGOUS_RESOURCEFUL_ACTION_NAMES[current_action_name])
      end
    end
  end
end
