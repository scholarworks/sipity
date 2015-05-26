module Sipity
  module Runners
    # Container for Work related actions.
    module WorkRunners
      # Responsible for instantiating the model for a Work
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_id:)
          work = repository.find_work(work_id)
          authorization_layer.enforce!(action_name => work) do
            callback(:success, work)
          end
        end
      end
    end
  end
end
