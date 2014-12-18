module Sipity
  # :nodoc:
  module RepositoryMethods
    # Citation related methods
    module CitationMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::CitationQueries)
        base.send(:include, Commands)
      end

      # Commands
      module Commands
        def submit_assign_a_citation_form(form, requested_by:)
          form.submit do |f|
            AdditionalAttributeMethods::Commands.update_header_attribute_values!(
              header: f.header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation
            )
            AdditionalAttributeMethods::Commands.update_header_attribute_values!(
              header: f.header, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type
            )
            EventLogMethods::Commands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
            f.header
          end
        end
      end
    end
  end
end
