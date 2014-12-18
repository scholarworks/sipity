module Sipity
  module Commands
    # Commands
    module CitationCommands
      def submit_assign_a_citation_form(form, requested_by:)
        form.submit do |f|
          RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(
            header: f.header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation
          )
          RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(
            header: f.header, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type
          )
          EventLogCommands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
          f.header
        end
      end
    end
  end
end
