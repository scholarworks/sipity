module Sipity
  module Runners
    # Container for Work related actions.
    module WorkRunners
      # Responsible for building the model for a New Work
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :create?

        def run(attributes: {})
          work = repository.build_create_work_form(attributes: attributes)
          authorization_layer.enforce!(action_name => work) do
            callback(:success, work)
          end
        end
      end

      # Responsible for creating and persisting a new Work
      class Create < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :create?

        def run(attributes:)
          form = repository.build_create_work_form(attributes: attributes)
          authorization_layer.enforce!(action_name => form) do
            work = form.submit(repository: repository, requested_by: current_user)
            if work
              callback(:success, work)
            else
              callback(:failure, form)
            end
          end
        end
      end

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

      # Responsible for finding and destroying the given work.
      class Destroy < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :destroy?

        def run(work_id:)
          work = repository.find_work(work_id)
          authorization_layer.enforce!(action_name => work) do
            # REVIEW: Do we want to do anything else?
            work.destroy
            callback(:success, work)
          end
        end
      end

      # Responsible for providing an index of Works
      class Index < BaseRunner
        self.authentication_layer = :default

        def run
          works = repository.find_works_for(user: current_user)
          callback(:success, works)
        end
      end

      # Responsible for instantiating the work for edit
      class Edit < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :submit?

        def run(work_id:)
          work = repository.find_work(work_id)
          form = repository.build_update_work_form(work: work)
          authorization_layer.enforce!(action_name => form) do
            callback(:success, form)
          end
        end
      end

      # Responsible for creating and persisting a new Work
      class Update < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :submit?

        def run(work_id:, attributes:)
          work = repository.find_work(work_id)
          form = repository.build_update_work_form(work: work, attributes: attributes)
          authorization_layer.enforce!(action_name => form) do
            work = form.submit(repository: repository, requested_by: current_user)
            if work
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
