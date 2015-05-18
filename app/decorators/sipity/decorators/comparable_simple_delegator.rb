module Sipity
  module Decorators
    # Provides a convenience wrapper of an object to assist in equality testing.
    # This is key as it relates to PowerConverter and how it is used.
    class ComparableSimpleDelegator < SimpleDelegator
      class_attribute :base_class, instance_writer: false

      def initialize(object, localization_assistant: default_localization_assistant)
        super(object)
        self.localization_assistant = localization_assistant
      end

      # Yup, I'm delegating the #class method to the localization assistant
      # Because Rails uses `object.class.human_attribute_name` or
      # `object.class.model_name` with great fervor.
      delegate :model_name, :class, to: :localization_assistant
      delegate :base_class, to: :singleton_class

      class << self
        def ===(other)
          super || base_class === other
        end
      end

      def is_a?(classification)
        # REVIEW: Is base_class == classification a reasonable assumption?
        #   Thinking in terms of Liskov's Substitution this may be necessary.
        super || __getobj__.is_a?(classification) || base_class == classification
      end

      alias_method :kind_of?, :is_a?

      private

      attr_accessor :localization_assistant

      def default_localization_assistant
        Decorators::LocalizationAssistant.new(base_class: base_class, decorating_class: singleton_class)
      end
    end
  end
end
