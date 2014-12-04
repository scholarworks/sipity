require 'sip/exceptions'
module Sip
  # Responsible for exposing attributes for editing
  #
  # TODO: Expose setter and getter methods for each :exposed_attribute_name
  class EditHeaderForm < VirtualForm
    def self.model_name
      Header.model_name
    end

    attr_reader :header
    def initialize(header:, exposed_attribute_names: [], attributes: {})
      @header = header
      @attributes = attributes.stringify_keys
      self.exposed_attribute_names = exposed_attribute_names
    end

    delegate :to_key, :to_param, :persisted?, to: :header

    def method_missing(method_name, *_args, &_block)
      if exposes?(method_name)
        @attributes[method_name.to_s]
      else
        super
      end
    end
    validates :title, presence: true

    def exposes?(method_name)
      @exposed_attribute_names.include?(method_name.to_s)
    end

    def respond_to_missing?(method_name, _include_private = false)
      exposes?(method_name) || super
    end

    private

    def exposed_attribute_names=(names)
      method_names = names.map(&:to_s)
      guard_against_existing_method_names!(method_names)
      @exposed_attribute_names = method_names
    end

    def guard_against_existing_method_names!(method_names)
      intersecting_methods = self.class.instance_methods.grep(/^(#{method_names.join('|')})/)
      if intersecting_methods.any?
        fail Sip::ExistingMethodsAlreadyDefined.new(self, intersecting_methods)
      else
        return true
      end
    end
  end
end
