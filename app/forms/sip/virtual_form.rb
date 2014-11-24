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
  end
end
