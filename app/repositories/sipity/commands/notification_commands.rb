module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      # @param notification [String] Name of the notification
      # @param entity [String] The entity that is the "subject" of the notification
      # @param to_roles [Array<String>]
      def send_notification_for_entity_trigger(notification:, entity:, to_roles:)
        # These instance variables are not needed; But to appeas Rubocop I'm
        # using them.
        to_emails = Queries::PermissionQueries.emails_for_associated_users(entity: entity, roles: to_roles)
        # TODO: Will we want to be logging this as an event?
        Services::Notifier.deliver(notification: notification, to: to_emails, entity: entity)
      end
    end
    private_constant :NotificationCommands
  end
end
