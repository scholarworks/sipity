module Sipity
  module Runners
    module DescriptionRunners
      # Responsible for responding with the correct form for the work's description
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:)
          work = repository.find_work(work_id)
          form = repository.build_create_describe_work_form(work: work)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end
    end
  end
end
