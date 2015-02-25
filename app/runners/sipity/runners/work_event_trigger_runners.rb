module Sipity
  module Runners
    module WorkEventTriggerRunners
      # Responsible for responding with the correct form for confirmation of the
      # triggering the named event
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(attributes = {})
          processing_action_name = attributes.fetch(:processing_action_name)
          work = repository.find_work(attributes.fetch(:work_id))
          form = repository.build_event_trigger_form(attributes.merge(work: work))
          authorization_layer.enforce!(processing_action_name => form) do
            callback(:success, form)
          end
        end
      end

      # Responsible for triggering the named event and responding accordingly.
      class Create < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(attributes = {})
          processing_action_name = attributes.fetch(:processing_action_name)
          work = repository.find_work(attributes.fetch(:work_id))
          form = repository.build_event_trigger_form(attributes.merge(work: work))
          authorization_layer.enforce!(processing_action_name => form) do
            if form.submit(repository: repository, requested_by: current_user)
              callback(:success, work)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
