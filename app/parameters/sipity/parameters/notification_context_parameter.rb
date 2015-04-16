module Sipity
  module Parameters
    # Responsible for consolidating the objects necessary for sending a
    # notification.
    class NotificationContextParameter
      attr_reader :action, :entity, :requested_by, :on_behalf_of
      def initialize(**keywords)
        self.entity = keywords.fetch(:entity)
        # TODO: Should this be converted to an action via a conversion method?
        self.action = keywords.fetch(:action)
        self.requested_by = keywords.fetch(:requested_by) { nil }
        self.on_behalf_of = keywords.fetch(:on_behalf_of) { requested_by }
      end

      private

      attr_writer :action, :entity, :requested_by, :on_behalf_of
    end
  end
end
