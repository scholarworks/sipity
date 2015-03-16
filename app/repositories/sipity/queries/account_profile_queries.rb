require 'sipity/forms/manage_account_profile_form'

module Sipity
  module Queries
    # Queries
    module AccountProfileQueries
      def build_account_profile_form(user:, attributes:)
        Forms::ManageAccountProfileForm.new(user: user, repository: self, **attributes)
      end
    end
  end
end
