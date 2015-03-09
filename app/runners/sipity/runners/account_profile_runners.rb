module Sipity
  module Runners
    # Container for account profile related actions.
    module AccountProfileRunners
      # Responsible for instantiating the account profile for edit
      class Edit < BaseRunner
        self.authentication_layer = ->(context) { context.authenticate_user_for_profile_management! }
        def run(attributes = {})
          form = repository.build_account_profile_form(attributes.merge(user: current_user))
          callback(:success, form)
        end
      end

      # Responsible for updating account profile
      class Update < Edit
        self.authentication_layer = ->(context) { context.authenticate_user_for_profile_management! }
        def run(attributes = {})
          form = repository.build_account_profile_form(attributes.merge(user: current_user))
          if form.submit(requested_by: current_user)
            callback(:success, current_user)
          else
            callback(:failure, form)
          end
        end
      end
    end
  end
end
