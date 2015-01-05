module Sipity
  module Decorators
    module Recommendations
      # Container for the Citation Recommendation
      class CitationRecommendation < Recommendations::Base
        def state
          return :citation_already_assigned if citation_already_assigned?
          return :citation_not_assigned
        end
        alias_method :status, :state

        def path_to_recommendation
          helper.sip_citation_path(sip)
        end

        private

        def citation_already_assigned?
          repository.citation_already_assigned?(sip)
        end
      end
    end
  end
end
