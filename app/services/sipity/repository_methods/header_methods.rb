module Sipity
  # :nodoc:
  module RepositoryMethods
    # Methods related to header creation
    module HeaderMethods
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries)
        base.send(:include, Commands)
      end

      module Queries
        def find_header(header_id)
          Models::Header.find(header_id)
        end

        # @todo Is this the right place for this? Should there a permanency layer?
        #   That is to say something responsible for resolving records and
        #   providing redirection.
        def permanent_uri_for_header_id(header_id)
          URI.parse("http://change.me/show/#{header_id}")
        end

        def find_headers_for(user:)
          # REVIEW: Is this bleeding into the authorization layer?
          Policies::HeaderPolicy::Scope.resolve(user: user, scope: Models::Header)
        end

        def build_create_header_form(attributes: {})
          Forms::CreateHeaderForm.new(attributes)
        end

        def build_update_header_form(header:, attributes: {})
          fail "Expected #{header} to be persisted" unless header.persisted?
          new_attributes = existing_header_attributes_for(header).merge(attributes)
          exposed_attribute_names = exposed_header_attribute_names_for(header: header)
          Forms::UpdateHeaderForm.new(header: header, exposed_attribute_names: exposed_attribute_names, attributes: new_attributes)
        end

        private

        def existing_header_attributes_for(header)
          # TODO: How to account for additional fields and basic fields of header
          existing_attributes = { title: header.title, work_publication_strategy: header.work_publication_strategy }
          Models::AdditionalAttribute.where(header: header).each_with_object(existing_attributes) do |attr, mem|
            # TODO: How to handle multi-value options
            mem[attr.key] = attr.value
          end
        end

        def exposed_header_attribute_names_for(header:, additional_attribute_names: BASE_HEADER_ATTRIBUTES)
          (
            AdditionalAttributeMethods.header_default_attribute_keys_for(header: header) +
            AdditionalAttributeMethods.header_attribute_keys_for(header: header) +
            additional_attribute_names
          ).uniq
        end
      end

      module Commands
        def update_processing_state!(header:, new_processing_state:)
          # REVIEW: Should this be re-finding the header? Is it cheating to re-use
          #   the given header? Is it unsafe as far as state is concerned?
          header.update(processing_state: new_processing_state)
        end

        def submit_create_header_form(form, requested_by:)
          form.submit do |f|
            Models::Header.create!(title: f.title, work_publication_strategy: f.work_publication_strategy) do |header|
              CollaboratorMethods::Commands.create_collaborators_for_header!(header: header, collaborators: f.collaborators)
              AdditionalAttributeMethods.update_header_publication_date!(header: header, publication_date: f.publication_date)
              Models::Permission.create!(entity: header, user: requested_by, role: Models::Permission::CREATING_USER) if requested_by
              EventLogMethods::Commands.log_event!(entity: header, user: requested_by, event_name: __method__) if requested_by
            end
          end
        end

        def submit_update_header_form(form, requested_by:)
          form.submit do |f|
            header = find_header(f.header.id)
            with_header_attributes_for_form(f) { |attributes| header.update(attributes) }
            with_each_additional_attribute_for_header_form(f) do |key, values|
              AdditionalAttributeMethods.update_header_attribute_values!(header: header, key: key, values: values)
            end
            EventLogMethods::Commands.log_event!(entity: header, user: requested_by, event_name: __method__) if requested_by
            header
          end
        end

        private

        def with_each_additional_attribute_for_header_form(form)
          AdditionalAttributeMethods.header_attribute_keys_for(header: form.header).each do |key|
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
    private_constant :HeaderMethods
  end
end
