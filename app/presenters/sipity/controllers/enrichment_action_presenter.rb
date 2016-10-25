require 'sipity/guard_interface_expectation'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Controllers
    # Responsible for presenting an enrichment action
    class EnrichmentActionPresenter < Curly::Presenter
      presents :enrichment_action

      attr_reader :enrichment_action
      private :enrichment_action

      delegate :name, to: :enrichment_action, prefix: :action

      include GuardInterfaceExpectation
      def initialize(context, options = {})
        # Because Curly template passes string keys, I need to check those as well; But symbols are convenient.
        self.enrichment_action_set = options.fetch(:enrichment_action_set) { options.fetch('enrichment_action_set') }
        self.repository = options.delete(:repository) { default_repository }
        super
        guard_interface_expectation!(enrichment_action_set, :entity)
        initialize_state_variables_for_interrogation!
      end

      def state
        return 'done' if complete?
        'incomplete'
      end

      def path
        # HACK: Is there a better method for collaboration? In doing this, I
        # might be able to get rid of several underlying classes; So composition
        # by a convention.
        root_path = PowerConverter.convert(entity, to: :processing_action_root_path)
        File.join(root_path, action_name)
      end

      delegate :identifier, :entity, to: :enrichment_action_set

      def button_class
        return 'btn-default' if complete?
        return 'btn-primary' if a_prerequisite?
        'btn-info'
      end

      attr_reader :complete
      alias complete? complete

      attr_reader :a_prerequisite
      alias a_prerequisite? a_prerequisite

      def label
        TranslationAssistant.call(
          scope: :processing_actions, subject: entity, object: enrichment_action.name, predicate: :label
        )
      end

      def todo_checkbox_element
        todo_circle + completion_mark_if_applicable
      end

      private

      def completion_mark_if_applicable
        return ''.html_safe unless complete?
        %(
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="complete-icon">
          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
          </svg>
        ).html_safe
      end

      def todo_circle
        "<span class='circle #{state}'></span>".html_safe
      end

      attr_accessor :repository
      attr_reader :enrichment_action_set

      include GuardInterfaceExpectation
      def enrichment_action_set=(input)
        guard_interface_expectation!(input, :entity, :identifier)
        @enrichment_action_set = input
      end

      def default_repository
        QueryRepository.new
      end

      def initialize_state_variables_for_interrogation!
        @complete = completed_action_ids.include?(enrichment_action.id)
        @a_prerequisite = action_ids_that_are_prerequisites.include?(enrichment_action.id)
      end

      def completed_action_ids
        @completed_action_ids ||= Array.wrap(repository.scope_statetegy_actions_that_have_occurred(entity: entity, pluck: :id))
      end

      def action_ids_that_are_prerequisites
        @action_ids_that_are_prerequisites ||= Array.wrap(
          repository.scope_strategy_actions_that_are_prerequisites(entity: entity, pluck: :id)
        )
      end
    end
  end
end
