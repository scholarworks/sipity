module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to comment and request
      # changes to the work on behalf of someone else.
      class RequestChangeOnBehalfOfForm < Forms::StateAdvancingActionForm

        private

        def save(requested_by:)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        end
      end
    end
  end
end
