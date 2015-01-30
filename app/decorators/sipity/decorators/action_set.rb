require_relative './actions'

module Sipity
  module Decorators
    # A service object to help query and build a heterogeneous set of actions
    # based on event_names.
    class ActionSet
      include Enumerable
      Action = Struct.new(:name, :availability_state) do
        def available?
          availability_state == 'available'
        end
      end

      UNKNOWN_CURRENT_ACTION = '__unknown_current_action__'.freeze

      attr_reader :entity, :current_action, :event_names, :repository, :actions
      def initialize(options = {})
        @entity = options.fetch(:entity)
        @event_names = Array.wrap(options.fetch(:event_names))
        @current_action = options.fetch(:current_action) { UNKNOWN_CURRENT_ACTION }
        @repository = options.fetch(:repository) { default_repository }
        build_actions!
      end

      delegate :each, :present?, :empty?, to: :actions

      private

      def build_actions!
        @actions = []
        Actions.action_names_without_current_action_and_analogies(current_action_name: current_action, action_names: event_names).each do |event_name|
          availability_state = determine_availability_state_for(event_name)
          @actions << Action.new(event_name, availability_state)
        end
      end

      def default_repository
        QueryRepository.new
      end

      def determine_availability_state_for(event_name)
        return 'available' if Actions::RESOURCEFUL_ACTION_NAMES.include?(event_name)
        return 'available' if are_all_of_the_required_todo_items_done_for_work?
        'unavailable'
      end

      def are_all_of_the_required_todo_items_done_for_work?
        if defined?(@are_all_of_the_required_todo_items_done_for_work)
          return @are_all_of_the_required_todo_items_done_for_work
        else
          @are_all_of_the_required_todo_items_done_for_work = repository.are_all_of_the_required_todo_items_done_for_work?(work: entity)
        end
      end
    end
  end
end
