module Sipity
  module Decorators
    # There are times when I need to decorate an object with additional
    # attributes; This is a helper class to handle that.
    class BaseObjectWithComposedAttributesDelegator < SimpleDelegator
      def initialize(base_object, **attributes)
        # Choosing an instance variable because I don't want to obliterate
        # a possible method on the base_object.
        @attributes = attributes
        super(base_object)
      end

      def is_a?(classification)
        # REVIEW: Is base_class == classification a reasonable assumption?
        #   Thinking in terms of Liskov's Substitution this may be necessary.
        super || __getobj__.is_a?(classification)
      end

      alias kind_of? is_a?

      private

      def method_missing(method_name, *args, &block)
        if __getobj__.respond_to?(method_name)
          __getobj__.send(method_name, *args, &block)
        elsif @attributes.key?(method_name)
          @attributes[method_name]
        end
      end

      def respond_to_missing?(method_name, *args)
        super || @attributes.key?(method_name)
      end
    end
  end
end
