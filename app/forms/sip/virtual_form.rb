module Sip
  # A Form data structure for validation and submission
  class VirtualForm
    include ActiveModel::Validations
    extend ActiveModel::Translation

    def to_key
      []
    end

    def to_param
      nil
    end

    def persisted?
      to_param.nil? ? false : true
    end

    def submit
      fail NotImplementedError, "Expected #{self.class} to implement #submit"
    end

    private

    def decorate(object:, decorator:)
      return object unless decorator.respond_to?(:decorate)
      begin
        object.is_a?(decorator) ? object : decorator.decorate(object)
      rescue TypeError
        # TODO: Is there a more elegant way to do this? I was encountering an
        # error in which is_a? was throwing an exception because the decorator
        # is a double and not a class or module.
        decorator.decorate(object)
      end
    end
  end
end
