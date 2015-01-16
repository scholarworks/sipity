module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::WorkQueries)
      end
      # TODO: This is duplicationed
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def update_processing_state!(work:, new_processing_state:)
        # REVIEW: Should this be re-finding the work? Is it cheating to re-use
        #   the given work? Is it unsafe as far as state is concerned?
        work.update(processing_state: new_processing_state)
      end

      def submit_update_work_form(form, requested_by:)
        form.submit do |f|
          work = find_work(f.work.id)
          with_work_attributes_for_form(f) { |attributes| work.update(attributes) }
          with_each_additional_attribute_for_work_form(f) do |key, values|
            AdditionalAttributeCommands.update_work_attribute_values!(work: work, key: key, values: values)
          end
          EventLogCommands.log_event!(entity: work, user: requested_by, event_name: __method__) if requested_by
          work
        end
      end

      private

      def with_each_additional_attribute_for_work_form(form)
        Queries::AdditionalAttributeQueries.work_attribute_keys_for(work: form.work).each do |key|
          next unless  form.exposes?(key)
          yield(key, form.public_send(key))
        end
      end

      def with_work_attributes_for_form(form)
        attributes = {}
        BASE_HEADER_ATTRIBUTES.each do |attribute_name|
          attributes[attribute_name] = form.public_send(attribute_name) if form.exposes?(attribute_name)
        end
        yield(attributes) if attributes.any?
      end
    end
    private_constant :WorkCommands
  end
end
