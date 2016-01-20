module Sipity
  module Decorators
    # Provides a convenience wrapper of an object to assist in equality testing.
    # This is key as it relates to PowerConverter and how it is used.
    class ComparableSimpleDelegator < SimpleDelegator
      class_attribute :base_class, instance_writer: false

      class << self
        def ===(other)
          super || base_class === other
        end

        # Because ActiveModel::Validations is included at the class level,
        # and thus makes assumptions. Without `.name` method, the validations
        # choke.
        #
        # @note This needs to be done after the ActiveModel::Validations,
        #   otherwise you will get the dreaded error:
        #
        #   ```console
        #   A copy of Sipity::Forms::SubmissionWindows::Ulra::StartASubmissionForm
        #   has been removed from the module tree but is still active!
        #   ```
        delegate :model_name, :name, :human_attribute_name, to: :base_class
      end

      delegate :model_name, to: :base_class

      def is_a?(classification)
        # REVIEW: Is base_class == classification a reasonable assumption?
        #   Thinking in terms of Liskov's Substitution this may be necessary.
        super || __getobj__.is_a?(classification) || base_class == classification
      end

      alias kind_of? is_a?
    end
  end
end
