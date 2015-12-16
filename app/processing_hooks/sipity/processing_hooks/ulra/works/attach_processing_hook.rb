require 'sipity/models/additional_attribute'
require 'sipity/forms/work_submissions/ulra/attach_form'
require 'sipity/parameters/notification_context_parameter'

module Sipity
  module ProcessingHooks
    module Ulra
      module Works
        # ```gherkin
        # Given a user updates their attached thesiss files
        # and has indicated their thesis files are complete
        # When this processing hook fires
        # Then notifications should be delivered for the given entity and its current state
        # ```
        module AttachProcessingHook
          module_function

          # When the Attach action is taken on a given ULRA Work, this method should be called.
          #
          # @note This is triggered from an action but delivers emails for the given state because not all states will have emails that
          #   should be sent.
          #
          # @api private
          # @see Sipity::ProcessingHooks.call for how this is called
          def call(entity:, repository: default_repository, **keywords)
            strategy_state = PowerConverter.convert_to_strategy_state(entity)
            return true unless attached_files_are_complete_for?(entity: entity, repository: repository)
            # Excluding :action keyword as I don't want to send that further down the call path; Its not relevant to delivering
            # a strategy based email.
            repository.deliver_notification_for(
              scope: strategy_state, the_thing: entity, repository: repository,
              reason: Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED, **keywords.except(:action)
            )
          end

          # @api private
          def attached_files_are_complete_for?(entity:, repository:)
            predicate_name = Models::AdditionalAttribute::ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME
            entity_completion_state = repository.work_attribute_values_for(work: entity, key: predicate_name, cardinality: 1)
            complete_state = Forms::WorkSubmissions::Ulra::AttachForm::COMPLETE_STATE
            return entity_completion_state == complete_state
          end

          def default_repository
            CommandRepository.new
          end
          private_class_method :default_repository
        end
      end
    end
  end
end
