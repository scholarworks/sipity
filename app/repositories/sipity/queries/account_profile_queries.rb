module Sipity
  module Queries
    # Queries
    module AccountProfileQueries
      def build_account_profile_form(user:, attributes:)
        Forms::Core::ManageAccountProfileForm.new(user: user, repository: self, attributes: attributes)
      end
    end
  end
end
