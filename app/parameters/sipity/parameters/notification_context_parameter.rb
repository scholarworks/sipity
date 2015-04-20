module Sipity
  module Parameters
    # Responsible for consolidating the objects necessary for sending a
    # notification.
    class NotificationContextParameter
      REASON_ACTION_IS_TAKEN = 'action_is_taken'.freeze
      attr_reader :scope, :reason, :the_thing, :requested_by, :on_behalf_of
      def initialize(**keywords)
        self.the_thing = keywords.fetch(:the_thing)
        # TODO: Should this be converted to an scope via a conversion method?
        self.scope = keywords.fetch(:scope)
        self.requested_by = keywords.fetch(:requested_by) { nil }
        self.on_behalf_of = keywords[:on_behalf_of] || requested_by
        self.reason = keywords.fetch(:reason) { default_reason }
      end

      alias_method :reason_for_notification, :reason
      deprecate :reason_for_notification

      private

      def default_reason
        REASON_ACTION_IS_TAKEN
      end

      attr_writer :scope, :the_thing, :requested_by, :on_behalf_of, :reason
    end
  end
end
