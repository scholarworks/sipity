module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      # Responsible for delivering notifications (i.e., email)
      # @param notification [String] Name of the notification
      # @param entity [String] The entity that is the "subject" of the notification
      # @param acting_as [Array<String>]
      # @return [void]
      def send_notification_for_entity_trigger(notification:, entity:, acting_as:)
        # These instance variables are not needed; But to appeas Rubocop I'm
        # using them.
        to_emails = Queries::PermissionQueries.emails_for_associated_users(entity: entity, acting_as: acting_as)
        # TODO: Will we want to be logging this as an event?
        Services::Notifier.deliver(notification: notification, to: to_emails, entity: entity)
      end
    end
  end
end
