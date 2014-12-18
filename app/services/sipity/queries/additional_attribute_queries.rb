module Sipity
  module Queries
    # Queries
    module AdditionalAttributeQueries
      def build_create_orcid_account_placeholder_form(attributes: {})
        Forms::CreateOrcidAccountPlaceholderForm.new(attributes)
      end
    end
  end
end
