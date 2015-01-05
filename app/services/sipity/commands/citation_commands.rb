module Sipity
  # :nodoc:
  module Commands
    # Commands
    module CitationCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::CitationQueries)
      end

      def submit_assign_a_citation_form(form, requested_by:)
        form.submit do |f|
          AdditionalAttributeCommands.update_sip_attribute_values!(
            sip: f.sip, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation
          )
          AdditionalAttributeCommands.update_sip_attribute_values!(
            sip: f.sip, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type
          )
          EventLogCommands.log_event!(entity: f.sip, user: requested_by, event_name: __method__)
          f.sip
        end
      end
    end
    private_constant :CitationCommands
  end
end
