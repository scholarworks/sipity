module Sipity
  module Queries
    # Queries
    module DescriptionQueries
      def build_create_describe_work_form(attributes = {})
        Forms::DescribeWorkForm.new(attributes)
      end
    end
  end
end
