require_relative './actions'

module Sipity
  module Decorators
    # A service object to help query and build a heterogeneous set of actions
    # based on event_names.
    class ActionSet
      include Enumerable

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
          @actions << Actions.build(name: event_name, entity: entity, repository: repository)
        end
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
