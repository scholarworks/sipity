require 'sipity/runners/base_runner'

module Sipity
  module Runners
    # Container for account profile related actions.
    module AccountProfileRunners
      # Responsible for instantiating the account profile for edit
      class Edit < BaseRunner
        self.authentication_layer = :authenticate_user_with_disregard_for_approval_of_terms_of_service
        self.authorization_layer = :none
        def run(attributes: {})
          form = repository.build_account_profile_form(requested_by: current_user, attributes: attributes)
          callback(:success, form)
        end
      end

      # Responsible for updating account profile
      class Update < BaseRunner
        self.authentication_layer = :authenticate_user_with_disregard_for_approval_of_terms_of_service
        self.authorization_layer = :none
        def run(attributes: {})
          form = repository.build_account_profile_form(requested_by: current_user, attributes: attributes)
          if form.submit
            callback(:success, current_user)
          else
            callback(:failure, form)
          end
        end
      end
    end
  end
end
