module Sip
  module Recommendations
    # Container for the DOI Recommendation
    class DoiRecommendation
      attr_reader :header, :repository
      private :repository

      def initialize(header:, repository: self.default_repository)
        @header = header
        @repository = repository
      end

      def state
        return :doi_already_assigned if doi_already_assigned?
        return :doi_request_is_pending if doi_request_is_pending?
        return :doi_not_assigned
      end
      alias_method :status, :state

      private

      def doi_request_is_pending?
        repository.doi_request_is_pending?(header)
      end

      def doi_already_assigned?
        repository.doi_already_assigned?(header)
      end

      def default_repository
        Repository.new
      end
    end
  end
end
