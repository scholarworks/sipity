# Because of the `const_defined?` I'm requiring the various sipity state
# machines
named_concept = File.basename(__FILE__, '.rb')
Dir[File.expand_path("../#{named_concept}/*.rb", __FILE__)].each do |filename|
  require_relative "./#{named_concept}/#{File.basename(filename)}"
end

module Sipity
  # A submodule that is responsible for handling all state changes.
  module StateMachines
    # Exposes the interface and expectations of that interface.
    #
    # REVIEW: As I was working on this solution, I was not pleased with the
    #   direction of interactions. However, I made a concession of convenience
    #   to "ship it".
    module Interface
      module_function

      def trigger!(options = {})
        entity = options.fetch(:entity)
        options.fetch(:user)
        options.fetch(:repository)
        options.fetch(:event_name).to_sym
        entity.work_type
        :trigger!
      end
    end

    module_function

    # The public facing API for the ETD Workflow
    def trigger!(options = {})
      entity = options.fetch(:entity)
      user = options.fetch(:user)
      repository = options.fetch(:repository)
      event_name = options.fetch(:event_name).to_sym
      builder = find_state_machine_for(work_type: entity.work_type)
      builder.new(entity: entity, user: user, repository: repository).
        trigger!(event_name, options.except(:entity, :user, :repository, :event_name))
    end

    def state_diagram_for(work_type:)
      find_state_machine_for(work_type: work_type).state_diagram
    end

    def available_event_triggers_for(user:, entity:, repository:)
      diagram = state_diagram_for(work_type: entity.work_type)
      acting_as = repository.user_can_act_as_the_following_on_entity(user: user, entity: entity)
      diagram.available_events_for_when_acting_as(current_state: entity.processing_state, acting_as: acting_as)
    end

    def find_state_machine_for(work_type:)
      state_machine_name_by_convention = "#{work_type.classify}StateMachine"
      if const_defined?(state_machine_name_by_convention)
        const_get(state_machine_name_by_convention)
      else
        fail Exceptions::StateMachineNotFoundError, name: state_machine_name_by_convention, container: self
      end
    end
  end
end
