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
    end
  end
end
