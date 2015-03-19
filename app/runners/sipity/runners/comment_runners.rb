module Sipity
  module Runners
    module CommentRunners
      # Responsible for instantiating the model
      class Index < BaseRunner
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
