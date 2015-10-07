require 'sipity/runners/base_runner'

module Sipity
  module Runners
    # Container for account profile related actions.
    module AccountProfileRunners
      # Responsible for instantiating the account profile for edit
      class Edit < BaseRunner
        delegate :current_user_for_profile_management, to: :context
        self.authentication_layer = ->(context) { context.authenticate_user_for_profile_management! }
        def run(attributes: {})
          form = repository.build_account_profile_form(requested_by: current_user_for_profile_management, attributes: attributes)
          callback(:success, form)
        end
      end

      # Responsible for updating account profile
      class Update < BaseRunner
        delegate :current_user_for_profile_management, to: :context
        self.authentication_layer = ->(context) { context.authenticate_user_for_profile_management! }
        def run(attributes: {})
          form = repository.build_account_profile_form(requested_by: current_user_for_profile_management, attributes: attributes)
          if form.submit
            callback(:success, current_user_for_profile_management)
          else
            callback(:failure, form)
          end
        end
      end
    end
  end
end
