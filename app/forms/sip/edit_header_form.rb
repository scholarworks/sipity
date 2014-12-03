module Sip
  # Responsible for exposing attributes for editing
  #
  # TODO: Expose setter and getter methods for each :exposed_attribute_name
  class EditHeaderForm
    attr_reader :header
    def initialize(header:, exposed_attribute_names: [], attributes: {})
      @header = header
      @attributes = attributes.stringify_keys
      @exposed_attribute_names = exposed_attribute_names.map(&:to_s)
    end

    def valid?
      false
    end

    def submit
      return false unless valid?
      return yield(self)
    end

    def method_missing(method_name, *_args, &_block)
      if @exposed_attribute_names.include?(method_name.to_s)
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

    def inspect
      ::Kernel.format(
        '#<%s:%#0x @header.to_param=%s @exposed_attribute_names=%s, @attributes=%s>',
        self.class, __id__, @header.to_param, @exposed_attribute_names.inspect, @attributes.inspect
      )
    end
  end
end
