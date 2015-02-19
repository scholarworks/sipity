module Sipity
  module Forms
    # Responsible for exposing attributes for editing a given work.
    #
    # Since a Work is a composite of many attributes from numerous sources
    # this object is a bit different.
    #
    # @see Sipity::Forms::UpdateWorkForm#guard_against_existing_method_names!
    # @see Sipity::Forms::UpdateWorkForm#exposes?
    # @see Sipity::Forms::UpdateWorkForm#method_missing
    # @see Sipity::Forms::UpdateWorkForm#respond_to_missing?
    class UpdateWorkForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def self.model_name
        Models::Work.model_name
      end

      def initialize(work:, exposed_attribute_names: [], attributes: {})
        @work = work
        @attributes = attributes.stringify_keys
        self.exposed_attribute_names = exposed_attribute_names
      end

      attr_reader :work
      delegate :to_key, :to_param, :persisted?, :to_processing_entity, to: :work

      def to_model
        work
      end

      def enrichment_type
        # TODO: This is magic; Working at removing the needs of enrichment_type
        'update'
      end

      validates :title, presence: true
      validates :work, presence: true

      def method_missing(method_name, *_args, &_block)
        if exposes?(method_name)
          @attributes[method_name.to_s]
        else
          super
        end
      end

      def exposes?(method_name)
        @exposed_attribute_names.include?(method_name.to_s)
      end

      def respond_to_missing?(method_name, _include_private = false)
        exposes?(method_name) || super
      end

      def submit(repository:, requested_by:)
        super() do |_form|
          # TODO: Switch to a repository method for updating attributes?
          with_work_attributes { |attributes| work.update(attributes) }
          with_each_additional_attribute do |key, values|
            repository.update_work_attribute_values!(work: work, key: key, values: values)
          end
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
          work
        end
      end

      private

      # TODO: This is duplicationed
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze

      def event_name
        File.join(self.class.to_s.demodulize.underscore, 'submit')
      end

      def with_each_additional_attribute
        # TODO: Rely on the repository for these methods, not direct access to the query
        Queries::AdditionalAttributeQueries.work_attribute_keys_for(work: work).each do |key|
          next unless  exposes?(key)
          yield(key, public_send(key))
        end
      end

      def with_work_attributes
        attributes = {}
        BASE_HEADER_ATTRIBUTES.each do |attribute_name|
          attributes[attribute_name] = public_send(attribute_name) if exposes?(attribute_name)
        end
        yield(attributes) if attributes.any?
      end

      def exposed_attribute_names=(names)
        method_names = names.map(&:to_s)
        guard_against_existing_method_names!(method_names)
        @exposed_attribute_names = method_names
      end

      def guard_against_existing_method_names!(method_names)
        return true unless method_names.present?
        intersecting_methods = self.class.instance_methods.grep(/^(#{method_names.join('|')})/)
        if intersecting_methods.any?
          fail Exceptions::ExistingMethodsAlreadyDefined.new(self, intersecting_methods)
        else
          return true
        end
      end
    end
  end
end
