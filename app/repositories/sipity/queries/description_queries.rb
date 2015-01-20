module Sipity
  module Queries
    # Queries
    module DescriptionQueries
      def build_create_describe_work_form(attributes = {})
        Forms::DescribeWorkForm.new(attributes)
      end

      # TODO: Consolidate :build_enrichment_form and
      #   :build_create_describe_work_form
      #
      # TODO: This is the wrong form, but works to solve the specified test.
      def build_enrichment_form(attributes = {})
        Forms::AttachFilesToWorkForm.new(attributes)
      end
    end
  end
end
