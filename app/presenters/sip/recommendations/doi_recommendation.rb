module Sip
  module Recommendations
    # Container for the DOI Recommendation
    class DoiRecommendation
      extend ActiveModel::Translation

      attr_reader :header, :repository, :helper
      private :repository, :helper

      def initialize(header:, repository: default_repository, helper: header.h)
        @header = header
        @repository = repository
        @helper = helper
      end

      def state
        return :doi_already_assigned if doi_already_assigned?
        return :doi_request_is_pending if doi_request_is_pending?
        return :doi_not_assigned
      end
      alias_method :status, :state

      def path_to_recommendation
        helper.sip_header_doi_path(header)
      end

      def name
        :doi
      end

      def t(name)
        public_send(name)
      end

      def human_attribute_name(name)
        self.class.human_attribute_name(name)
      end

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
