require 'sipity/guard_interface_expectation'

module Sipity
  module Controllers
    # Responsible for presenting an state advancing action
    class StateAdvancingActionPresenter < Curly::Presenter
      STATE_AVAILABLE = 'available'.freeze
      STATE_PREREQUISITES_NOT_MET = 'unavailable'.freeze

      presents :state_advancing_action

      attr_reader :state_advancing_action
      private :state_advancing_action

      delegate :name, to: :state_advancing_action, prefix: :action

      def initialize(context, options = {})
        # Because Curly template passes string keys, I need to check those as well; But symbols are convenient.
        self.state_advancing_action_set = options.fetch(:state_advancing_action_set) { options.fetch('state_advancing_action_set') }
        self.repository = options.delete(:repository) { default_repository }
        super
        initialize_state_variables_for_interrogation!
      end

      attr_reader :available
      alias available?  available

      def availability_state
        available? ? STATE_AVAILABLE : STATE_PREREQUISITES_NOT_MET
      end

      def path
        # HACK: Is there a better method for collaboration? In doing this, I
        # might be able to get rid of several underlying classes; So composition
        # by a convention.
        root_path = PowerConverter.convert(entity, to: :processing_action_root_path)
        File.join(root_path, action_name)
      end

      def label
        TranslationAssistant.call(
          scope: :processing_actions, subject: entity, object: state_advancing_action.name, predicate: :label
        )
      end

      private

      attr_accessor :repository
      attr_reader :state_advancing_action, :state_advancing_action_set

      def default_repository
        QueryRepository.new
      end

      delegate :entity, to: :state_advancing_action_set
      include GuardInterfaceExpectation
      def state_advancing_action_set=(input)
        guard_interface_expectation!(input, :entity)
        @state_advancing_action_set = input
      end

      def initialize_state_variables_for_interrogation!
        @available = !prerequisites_not_met_action_ids.include?(state_advancing_action.id)
      end

      def prerequisites_not_met_action_ids
        repository.scope_strategy_actions_with_incomplete_prerequisites(entity: entity, pluck: :id)
      end
    end
  end
end
