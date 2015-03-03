require 'sipity/forms/manage_account_profile_form'

module Sipity
  module Queries
    # Queries
    module AccountProfileQueries
      def build_account_profile_form(attributes:)
        Forms::ManageAccountProfileForm.new(attributes)
      end
    end
  end
end
