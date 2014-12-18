module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      def send_notification_for_entity_trigger(notification:, entity:, to_roles:)
        # These instance variables are not needed; But to appeas Rubocop I'm
        # using them.
        @notification, @entity, @to_roles = notification, entity, to_roles
      end
    end
    private_constant :NotificationCommands
  end
end
