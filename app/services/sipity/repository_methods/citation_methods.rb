module Sipity
  # :nodoc:
  module RepositoryMethods
    # Citation related methods
    module CitationMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries)
        base.send(:include, Commands)
      end

      # Queries
      module Queries
        def citation_already_assigned?(header)
          AdditionalAttributeMethods.header_attribute_values_for(
            header: header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME
          ).any?
        end

        def build_assign_a_citation_form(attributes = {})
          Forms::AssignACitationForm.new(attributes)
        end
      end


      # Commands
      module Commands
        def submit_assign_a_citation_form(form, requested_by:)
          form.submit do |f|
            AdditionalAttributeMethods.update_header_attribute_values!(
              header: f.header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation
            )
            AdditionalAttributeMethods.update_header_attribute_values!(
              header: f.header, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type
            )
            EventLogMethods::Commands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
            f.header
          end
        end
      end
    end
    private_constant :CitationMethods
  end
end
