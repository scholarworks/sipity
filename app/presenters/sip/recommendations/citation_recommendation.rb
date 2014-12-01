module Sip
  module Recommendations
    # Container for the Citation Recommendation
    class CitationRecommendation < Recommendations::Base
      def state
        return :citation_already_assigned if citation_already_assigned?
        return :citation_not_assigned
      end
      alias_method :status, :state

      def path_to_recommendation
        helper.sip_header_citation_path(header)
      end

      private

      def citation_already_assigned?
        repository.citation_already_assigned?(header)
      end
    end
  end
end