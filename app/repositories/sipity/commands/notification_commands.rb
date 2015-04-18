module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      # Responsible for delivering notifications (i.e., email)
      # @param notification [String] Name of the notification
      # @param roles_for_recipients [Hash]
      # @param entity [String] The entity that is the "subject" of the notification
      # @option roles_for_recipients [Array<String>] :acting_as
      # @option roles_for_recipients [Array<String>] :cc role (names) to use to find associated emails to send as :cc
      # @option roles_for_recipients [Array<String>] :bcc role (names) to use to find associated emails to send as :to
      # @return [void]
      def send_notification_for_entity_trigger(notification:, entity:, **roles_for_recipients)
        Services::Notifier.deliver(
          notification: notification,
          entity: entity,
          to: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:acting_as]),
          cc: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:cc]),
          bcc: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:bcc])
        )
      end

      private

      def convert_recipient_roles_to_email(entity:, roles:)
        return [] unless roles.present?
        Queries::ProcessingQueries.user_emails_for_entity_and_roles(entity: entity, roles: roles)
      end
    end
  end
end
