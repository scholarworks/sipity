module Sipity
  # :nodoc:
  module Commands
    # Commands
    module HeaderCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::HeaderQueries)
      end
      # TODO: This is duplicationed
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def update_processing_state!(header:, new_processing_state:)
        # REVIEW: Should this be re-finding the header? Is it cheating to re-use
        #   the given header? Is it unsafe as far as state is concerned?
        header.update(processing_state: new_processing_state)
      end

      def submit_create_header_form(form, requested_by:)
        form.submit do |f|
          header = Models::Header.create!(title: f.title, work_publication_strategy: f.work_publication_strategy)
          CollaboratorCommands.create_collaborators_for_header!(header: header, collaborators: f.collaborators)
          AdditionalAttributeCommands.update_header_publication_date!(header: header, publication_date: f.publication_date)
          PermissionCommands.grant_creating_user_permission_for!(entity: header, user: requested_by)
          EventLogCommands.log_event!(entity: header, user: requested_by, event_name: __method__)
          header
        end
      end

      def submit_update_header_form(form, requested_by:)
        form.submit do |f|
          header = find_header(f.header.id)
          with_header_attributes_for_form(f) { |attributes| header.update(attributes) }
          with_each_additional_attribute_for_header_form(f) do |key, values|
            AdditionalAttributeCommands.update_header_attribute_values!(header: header, key: key, values: values)
          end
          EventLogCommands.log_event!(entity: header, user: requested_by, event_name: __method__) if requested_by
          header
        end
      end

      private

      def with_each_additional_attribute_for_header_form(form)
        Queries::AdditionalAttributeQueries.header_attribute_keys_for(header: form.header).each do |key|
          next unless  form.exposes?(key)
          yield(key, form.public_send(key))
        end
      end

      def with_header_attributes_for_form(form)
        attributes = {}
        BASE_HEADER_ATTRIBUTES.each do |attribute_name|
          attributes[attribute_name] = form.public_send(attribute_name) if form.exposes?(attribute_name)
        end
        yield(attributes) if attributes.any?
      end
    end
    private_constant :HeaderCommands
  end
end