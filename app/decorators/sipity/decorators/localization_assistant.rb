module Sipity
  module Decorators
    # The Localization Assistant must double as the object's class.
    #
    # One reason for these antics is that Rails translations make heavy use
    # of the class method `ActiveModel::Base.human_attribute_name`. This is
    # painful because in order to circumvent column name translations, I must
    # override the object's `#class` instance method.
    #
    # This object is here to help with that. It provides a pattern for stepping
    # in and helping with translations.
    #
    # @example
    #
    #   class Book < ActiveRecord::Base
    #     def initialize(*args, &block)
    #       super
    #       @localization_assistant = Sipity::Decorators::LocalizationAssistant.new(
    #          decorating_class: singleton_class, base_class: CreativeWork
    #       )
    #     end
    #     delegate :class, :model_name, to: :@localization_assistant
    #   end
    #
    class LocalizationAssistant
      # I want a clean room that delegates most of its responsibilities down to
      # the associated singleton_class.
      #
      # A BasicObject doesn't work because :respond_to? gets obliterated in that
      # implementation.
      METHOD_NAMES_TO_KEEP = [:respond_to?, :__id__, :__send__, :send, :public_send].freeze
      instance_methods.each do |method_name|
        undef_method(method_name) unless METHOD_NAMES_TO_KEEP.include?(method_name)
      end

      # Given how this is to be used, I believe the :decorating_class will need
      # to be the initializing object's #singleton_class; See the above example.
      def initialize(decorating_class:, base_class:)
        self.decorating_class = decorating_class
        self.base_class = base_class
      end

      # REVIEW: do I want the given model name to be a wrapper for the base_class's
      #   model_name? The reason I'm curious is if we want a custom param_key for the
      #   given object?
      delegate :human_attribute_name, :model_name, to: :base_class

      # Included because developers should know what the heck this object is.
      def inspect
        format(
          '#<%s:%#0x @decorating_class=%s @base_class=%s>',
          "Sipity::Decorators::LocalizationAssistant",
          __id__,
          decorating_class.inspect,
          base_class.inspect
        )
      end

      # As per the above example, I want to be able to delegate an object's
      # #class instance_method to an instance of this object.
      def class
        self
      end

      attr_reader :base_class, :decorating_class

      private

      attr_writer :base_class, :decorating_class

      def method_missing(method_name, *args, &block)
        decorating_class.send(method_name, *args, &block)
      end

      def respond_to_missing?(*args)
        decorating_class.respond_to?(*args)
      end
    end
  end
end
