module Sip
  # Responsible for exposing attributes for editing
  #
  # TODO: Expose setter and getter methods for each :exposed_attribute_name
  #
  # Implemented as a BasicObject to expose the most basic of methods, as I'm
  # instead relying on :method_missing and :respond_to_missing?.
  class EditHeaderForm < BasicObject
    def initialize(header:, exposed_attribute_names: [], attributes: {})
      @header = header
      @attributes = attributes.stringify_keys
      @exposed_attribute_names = exposed_attribute_names.map(&:to_s)
    end

    def method_missing(method_name, *_args, &_block)
      if @exposed_attribute_names.include?(method_name.to_s)
        @attributes[method_name.to_s]
      else
        super
      end
    end

    def send(*args)
      method_missing(*args)
    end
    alias_method :public_send, :send

    def respond_to_missing?(method_name, _include_private = false)
      @exposed_attribute_names.include?(method_name.to_s)
    end

    def respond_to?(method_name)
      respond_to_missing?(method_name) ||
        self.class.instance_methods.include?(method_name)
    end

    def a?(klass)
      klass == self.class
    end
    alias_method :kind_of?, :a?
    alias_method :is_a?, :a?

    def class
      EditHeaderForm
    end

    def inspect
      ::Kernel.format(
        '#<%s:%#0x @header.to_param=%s @exposed_attribute_names=%s, @attributes=%s>',
        self.class, __id__, @header.to_param, @exposed_attribute_names.inspect, @attributes.inspect
      )
    end
  end
end
