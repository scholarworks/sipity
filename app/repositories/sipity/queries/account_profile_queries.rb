module Sipity
  module Queries
    # Queries
    module AccountProfileQueries
      def build_account_profile_form(requested_by:, attributes:)
        Forms::Core::ManageAccountProfileForm.new(requested_by: requested_by, repository: self, attributes: attributes)
      end
    end
  end
end
