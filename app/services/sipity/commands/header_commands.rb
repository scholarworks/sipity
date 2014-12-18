module Sipity
  module Commands
    # Commands
    module HeaderCommands
      # TODO: This is duplicationed
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def update_processing_state!(header:, new_processing_state:)
        # REVIEW: Should this be re-finding the header? Is it cheating to re-use
        #   the given header? Is it unsafe as far as state is concerned?
        header.update(processing_state: new_processing_state)
      end

      def submit_create_header_form(form, requested_by:)
        form.submit do |f|
          Models::Header.create!(title: f.title, work_publication_strategy: f.work_publication_strategy) do |header|
            CollaboratorCommands.create_collaborators_for_header!(header: header, collaborators: f.collaborators)
            RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_publication_date!(
              header: header, publication_date: f.publication_date
            )
            Models::Permission.create!(entity: header, user: requested_by, role: Models::Permission::CREATING_USER) if requested_by
            Sipity::Commands::EventLogCommands.log_event!(entity: header, user: requested_by, event_name: __method__) if requested_by
          end
        end
      end

      def submit_update_header_form(form, requested_by:)
        form.submit do |f|
          header = find_header(f.header.id)
          with_header_attributes_for_form(f) { |attributes| header.update(attributes) }
          with_each_additional_attribute_for_header_form(f) do |key, values|
            RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(header: header, key: key, values: values)
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
  end
end
