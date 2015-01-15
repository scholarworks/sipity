module Sipity
  module Queries
    # Queries
    module WorkQueries
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def find_work(work_id)
        Models::Work.find(work_id)
      end

      # @todo Is this the right place for this? Should there a permanency layer?
      #   That is to say something responsible for resolving records and
      #   providing redirection.
      def permanent_uri_for_work_id(work_id)
        URI.parse("http://change.me/show/#{work_id}")
      end

      def find_works_for(user:)
        # REVIEW: Is this bleeding into the authorization layer?
        Policies::WorkPolicy::Scope.resolve(user: user, scope: Models::Work)
      end

      def build_create_work_form(attributes: {})
        Forms::CreateWorkForm.new(attributes)
      end

      def build_update_work_form(work:, attributes: {})
        fail "Expected #{work} to be persisted" unless work.persisted?
        new_attributes = existing_work_attributes_for(work).merge(attributes)
        exposed_attribute_names = exposed_work_attribute_names_for(work: work)
        Forms::UpdateWorkForm.new(work: work, exposed_attribute_names: exposed_attribute_names, attributes: new_attributes)
      end

      private

      def existing_work_attributes_for(work)
        # TODO: How to account for additional fields and basic fields of work
        existing_attributes = { title: work.title, work_publication_strategy: work.work_publication_strategy }
        Models::AdditionalAttribute.where(work: work).each_with_object(existing_attributes) do |attr, mem|
          # TODO: How to handle multi-value options
          mem[attr.key] = attr.value
        end
      end

      def exposed_work_attribute_names_for(work:, additional_attribute_names: BASE_HEADER_ATTRIBUTES)
        (
          AdditionalAttributeQueries.work_default_attribute_keys_for(work: work) +
          AdditionalAttributeQueries.work_attribute_keys_for(work: work) +
          additional_attribute_names
        ).uniq
      end
    end
  end
end