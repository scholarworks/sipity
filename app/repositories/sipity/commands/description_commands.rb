module Sipity
  # :nodoc:
  module Commands
    # Commands
    module DescriptionCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::DescriptionQueries)
      end

      def submit_description_form(form, requested_by:)
        form.submit do |f|
          AdditionalAttributeCommands.update_work_attribute_values!(
            work: f.work, key: Models::AdditionalAttribute::ABSTRACT_PREDICATE_NAME, values: f.abstract
          )
          EventLogCommands.log_event!(entity: f.work, user: requested_by, event_name: __method__)
          f.work
        end
      end
    end
    private_constant :DescriptionCommands
  end
end
