require 'sipity/runners/base_runner'

module Sipity
  module Runners
    # Container for Dashboard related actions.
    module DashboardRunners
      # Responsible for building a general view object for the dashboard.
      class Index < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :none

        def run(processing_state: nil, page: 1)
          dashboard_view = repository.build_dashboard_view(user: current_user, filter: { processing_state: processing_state }, page: page)
          callback(:success, dashboard_view)
        end
      end
    end
  end
end
