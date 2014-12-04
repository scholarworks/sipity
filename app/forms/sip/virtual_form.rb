module Sip
  # A Form data structure for validation and submission. This is envisioned as a
  # non-persisted representation.
  #
  # @see #to_key
  # @see #to_param
  # @see #submit
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

    # @return false if the form was not valid
    # @return true if the form was valid and the caller's submission block was
    #   successful
    # @yield [VirtualForm] when the form is valid yield control to the caller
    # @yieldparam form [VirtualForm]
    # @yieldreturn the sender's response successful
    def submit
      return false unless valid?
      return yield(self)
    end
  end
end
