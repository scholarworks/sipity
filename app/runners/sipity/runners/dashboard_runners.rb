module Sipity
  module Runners
    # Container for Dashboard related actions.
    module DashboardRunners
      # Responsible for building a general view object for the dashboard.
      class Index < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :none

        def run(processing_state: nil)
          works = repository.find_works_for(user: current_user, processing_state: processing_state)
          callback(:success, works)
        end
      end
    end
  end
end
