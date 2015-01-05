module Sipity
  module Queries
    # Queries
    module SipQueries
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def find_sip(sip_id)
        Models::Sip.find(sip_id)
      end

      # @todo Is this the right place for this? Should there a permanency layer?
      #   That is to say something responsible for resolving records and
      #   providing redirection.
      def permanent_uri_for_sip_id(sip_id)
        URI.parse("http://change.me/show/#{sip_id}")
      end

      def find_sips_for(user:)
        # REVIEW: Is this bleeding into the authorization layer?
        Policies::SipPolicy::Scope.resolve(user: user, scope: Models::Sip)
      end

      def build_create_sip_form(attributes: {})
        Forms::CreateSipForm.new(attributes)
      end

      def build_update_sip_form(sip:, attributes: {})
        fail "Expected #{sip} to be persisted" unless sip.persisted?
        new_attributes = existing_sip_attributes_for(sip).merge(attributes)
        exposed_attribute_names = exposed_sip_attribute_names_for(sip: sip)
        Forms::UpdateSipForm.new(sip: sip, exposed_attribute_names: exposed_attribute_names, attributes: new_attributes)
      end

      private

      def existing_sip_attributes_for(sip)
        # TODO: How to account for additional fields and basic fields of sip
        existing_attributes = { title: sip.title, work_publication_strategy: sip.work_publication_strategy }
        Models::AdditionalAttribute.where(sip: sip).each_with_object(existing_attributes) do |attr, mem|
          # TODO: How to handle multi-value options
          mem[attr.key] = attr.value
        end
      end

      def exposed_sip_attribute_names_for(sip:, additional_attribute_names: BASE_HEADER_ATTRIBUTES)
        (
          AdditionalAttributeQueries.sip_default_attribute_keys_for(sip: sip) +
          AdditionalAttributeQueries.sip_attribute_keys_for(sip: sip) +
          additional_attribute_names
        ).uniq
      end
    end
  end
end
