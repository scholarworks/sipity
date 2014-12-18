module Sipity
  module RepositoryMethods
    module Queries
      # A container for account place holder query objects
      module AccountPlaceholderQueries
        # HACK: This is a query method
        def build_create_orcid_account_placeholder_form(attributes: {})
          Forms::CreateOrcidAccountPlaceholderForm.new(attributes)
        end
      end
    end
  end
end
