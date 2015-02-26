module Sipity
  module Forms
    module Etd
      # Responsible for capturing advisor comments and forwarding them on to
      # the student.
      class AdvisorRequestsChangeForm < ProcessingActionForm
        def initialize(attributes = {})
          super
          @comment = attributes[:comment]
          self.action = attributes.fetch(:processing_action_name) { default_processing_action_name }
        end

        attr_reader :action, :comment
        validates :comment, presence: true

        def processing_action_name
          action.name
        end

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          f.input(:comment, as: :text, autofocus: true)
        end

        private

        def save(repository:, requested_by:)
          super do
            repository.record_processing_comment(entity: work, commenter: requested_by, comment: comment, action: action)
            repository.send_notification_for_entity_trigger(
              notification: 'advisor_requests_change',
              entity: work,
              acting_as: ['creating_user']
            )
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
          end
        end

        def enrichment_type
          self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
        end
        alias_method :default_processing_action_name, :enrichment_type

        include Conversions::ConvertToProcessingAction
        def action=(value)
          @action = convert_to_processing_action(value, scope: to_processing_entity)
        end
      end
    end
  end
end
