module Sipity
  module Forms
    # A Form data structure for validation and submission.
    #
    # I'm including persistence related methods so this behaves "well enough"
    # for a Rails form_for (or simple_form_for) tag.
    #
    # @see #to_key
    # @see #to_param
    # @see #submit
    class BaseForm
      include ActiveModel::Validations
      extend ActiveModel::Translation
      class_attribute :policy_enforcer

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
      #
      # @return truthy if the form was valid and the caller's submission block was
      #   successful
      #
      # @yield [BaseForm] when the form is valid yield control to the caller
      # @yieldparam form [BaseForm]
      # @yieldreturn the sender's response successful
      #
      # REVIEW: Rework to account for submit handling the save behavior
      #   Allow repository and requested_by to be passed; Consider setting those
      #   values on initialization instead.
      def submit
        return false unless valid?
        return yield(self)
      end
    end
  end
end
