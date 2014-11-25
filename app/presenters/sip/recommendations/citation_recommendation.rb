module Sip
  module Recommendations
    # Container for the Citation Recommendation
    class CitationRecommendation
      extend ActiveModel::Translation

      attr_reader :header, :repository, :helper
      private :repository, :helper

      def initialize(header:, repository: default_repository, helper: header.h)
        @header = header
        @repository = repository
        @helper = helper
      end

      def state
        return :citation_already_assigned if citation_already_assigned?
        return :citation_not_assigned
      end
      alias_method :status, :state

      def path_to_recommendation
        helper.sip_header_citation_path(header)
      end

      def human_status
        I18n.translate("status.#{state}", scope: self.class.model_name.i18n_key, title: header.title)
      end

      def human_name
        I18n.translate("name", scope: self.class.model_name.i18n_key)
      end

      def human_attribute_name(name)
        self.class.human_attribute_name(name)
      end

      private

      def citation_already_assigned?
        repository.citation_already_assigned?(header)
      end

      def default_repository
        Repository.new
      end
    end
  end
end
