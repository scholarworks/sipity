module Sipity
  module Commands
    # Commands
    module AdditionalAttributeCommands
      def submit_create_orcid_account_placeholder_form(form, requested_by:)
        form.submit do |f|
          placeholder = Models::AccountPlaceholder.create!(
            identifier: f.identifier, identifier_type: Models::AccountPlaceholder::ORCID_IDENTIFIER_TYPE,
            name: f.name
          )
          Models::Permission.create!(entity: placeholder, user: requested_by, role: Models::Permission::CREATING_USER)
          RepositoryMethods::EventLogMethods::Commands.log_event!(entity: placeholder, user: requested_by, event_name: __method__)
          placeholder
        end
      end
    end
  end
end
