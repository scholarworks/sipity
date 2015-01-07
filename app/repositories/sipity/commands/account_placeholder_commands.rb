module Sipity
  # :nodoc:
  module Commands
    # Commands
    module AccountPlaceholderCommands
      # HACK: This is a stop gap
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::AccountPlaceholderQueries)
      end

      def submit_create_orcid_account_placeholder_form(form, requested_by:)
        form.submit do |f|
          identifier_type = Models::AccountPlaceholder::ORCID_IDENTIFIER_TYPE
          placeholder = Models::AccountPlaceholder.create!(identifier: f.identifier, identifier_type: identifier_type, name: f.name)
          PermissionCommands.grant_creating_user_permission_for!(entity: placeholder, user: requested_by)
          EventLogCommands.log_event!(entity: placeholder, user: requested_by, event_name: __method__)
          placeholder
        end
      end
    end
    private_constant :AccountPlaceholderCommands
  end
end
