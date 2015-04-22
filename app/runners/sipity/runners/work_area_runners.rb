module Sipity
  module Runners
    module WorkAreaRunners
      # Responsible for responding with a work area
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_area_slug:)
          work_area = repository.find_work_area_by(slug: work_area_slug)
          authorization_layer.enforce!(action_name => work_area) do
            callback(:success, work_area)
          end
        end
      end
    end
  end
end
