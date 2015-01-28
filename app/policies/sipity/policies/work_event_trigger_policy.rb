module Sipity
  module Policies
    # Responsible for enforcing a user attempting to trigger an event on
    # the given work.
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    # @see WorkPolicy for more information on who can edit this object.
    class WorkEventTriggerPolicy < BasePolicy
      def initialize(user, entity, collaborators = {})
        self.user = user
        self.entity = entity
        @repository = collaborators.fetch(:repository) { default_repository }
      end

      define_action_to_authorize :submit? do
        return false unless user.present?
        return false unless work.persisted?
        return false unless valid_state_transition?
        return false unless all_required_todo_items_are_done?
        return false unless user_can_trigger_event_for_work?
        true
      end

      alias_method :form, :entity
      attr_reader :work, :repository

      private

      def valid_state_transition?
        # This may be a duplication of logic, but it prevents a database hit.
        processing_state_actors_for_event_name.present?
      end

      def user_can_trigger_event_for_work?
        allowed_if_acting_as = processing_state_actors_for_event_name
        repository.can_the_user_act_on_the_entity?(user: user, acting_as: allowed_if_acting_as, entity: work)
      end

      def processing_state_actors_for_event_name
        # TODO: Need a better state diagram, see below.
        @processing_state_actors_for_event_name ||= form.state_diagram.fetch(work.processing_state, {}).fetch(event_name_for_lookup, [])
      end

      def all_required_todo_items_are_done?
        repository.are_all_of_the_required_todo_items_done_for_work?(work: work)
      end

      def event_name_for_lookup
        "#{form.event_name}?".to_sym
      end

      def entity=(object)
        if object.respond_to?(:work) && object.work.present? && object.respond_to?(:event_name) && object.event_name.present?
          super(object)
          self.work = object.work
        else
          fail Exceptions::PolicyEntityExpectationError, "Expected #{object} to have a #work and #event_name."
        end
      end

      def work=(object)
        # A Subtle violation of demeter; I already have asked the entity for the work
        if object.respond_to?(:processing_state) && object.processing_state.present?
          @work = object
        else
          fail Exceptions::PolicyEntityExpectationError, "Expected #{object} to have a #processing_state."
        end
      end

      def default_repository
        Repository.new
      end
    end
  end
end
