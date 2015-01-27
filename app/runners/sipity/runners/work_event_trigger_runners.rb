module Sipity
  module Runners
    module WorkEventTriggerRunners
      # Responsible for responding with the correct form for the work's description
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, event_name:)
          work = repository.find_work(work_id)
          form = repository.build_event_trigger_form(work: work, event_name: event_name)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end
    end
  end
end
