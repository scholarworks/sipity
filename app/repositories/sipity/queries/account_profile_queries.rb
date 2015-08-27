module Sipity
  module Queries
    # Queries
    module AccountProfileQueries
      def build_account_profile_form(requested_by:, attributes:)
        Forms::Core::ManageAccountProfileForm.new(requested_by: requested_by, repository: self, attributes: attributes)
      end

      def agreed_to_application_terms_of_service?(identifier_id:)
        # Order of this query's commands matter.
        Sipity::Models::AgreedToTermsOfService.where.not(agreed_at: nil).where(identifier_id: identifier_id).count > 0
      end
    end
  end
end
