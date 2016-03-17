require 'sipity/runners/base_runner'
require 'sipity/controllers/work_areas/etd/show_presenter'

module Sipity
  module Runners
    module VisitorsRunner
      # Responsible for retrieving the given work area
      class WorkArea < BaseRunner
        self.authentication_layer = :none
        # @note Some of the methods that invoke the runners assume :processing_action_name, however this one does not need it. Thus I am
        # swallowing :processing_action_name keyword arg in the double splat (**_keywords) operator.
        def run(work_area_slug:, **_keywords)
          enforce_authentication! # No authentication required; but I'd prefer to follow the authentication layer convention
          work_area = repository.find_work_area_by(slug: work_area_slug)
          callback(:success, work_area)
        end
      end
    end
  end
end
