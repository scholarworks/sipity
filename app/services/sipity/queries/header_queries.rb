module Sipity
  module Queries
    # Queries
    module HeaderQueries
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
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
          RepositoryMethods::AdditionalAttributeMethods::Queries.header_default_attribute_keys_for(header: header) +
          RepositoryMethods::AdditionalAttributeMethods::Queries.header_attribute_keys_for(header: header) +
          additional_attribute_names
        ).uniq
      end
    end
  end
end
