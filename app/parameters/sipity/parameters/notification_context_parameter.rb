module Sipity
  module Parameters
    # Responsible for consolidating the objects necessary for sending a
    # notification.
    class NotificationContextParameter
      NOTIFYING_CONTEXT_ACTION_IS_TAKEN = 'action_is_taken'.freeze
      attr_reader :action, :the_thing, :requested_by, :on_behalf_of
      def initialize(**keywords)
        self.the_thing = keywords.fetch(:the_thing)
        # TODO: Should this be converted to an action via a conversion method?
        self.action = keywords.fetch(:action)
        self.requested_by = keywords.fetch(:requested_by) { nil }
        self.on_behalf_of = keywords[:on_behalf_of] || requested_by
      end

      def reason_for_notification
        NOTIFYING_CONTEXT_ACTION_IS_TAKEN
      end

      private

      attr_writer :action, :the_thing, :requested_by, :on_behalf_of
    end
  end
end
