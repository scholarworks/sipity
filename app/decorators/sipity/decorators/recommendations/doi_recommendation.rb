module Sipity
  module Decorators
    module Recommendations
      # Container for the DOI Recommendation
      class DoiRecommendation < Recommendations::Base
        def state
          return :doi_already_assigned if doi_already_assigned?
          return :doi_request_is_pending if doi_request_is_pending?
          return :doi_not_assigned
        end
        alias_method :status, :state

        def path_to_recommendation
          helper.work_doi_path(work)
        end

        private

        def doi_request_is_pending?
          repository.doi_request_is_pending?(work)
        end

        def doi_already_assigned?
          repository.doi_already_assigned?(work)
        end
      end
    end
  end
end
