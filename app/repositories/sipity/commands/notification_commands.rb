module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      # Responsible for delivering notifications (i.e. emails)
      # @param scope [Object]
      # @param the_thing [Object] what are you going to be building most of the email content from?
      # @param keywords [Hash] additional keywords; See Sipity::Parameters::NotificationContextParameter
      # @return [void]
      #
      # @see Parameters::NotificationContextParameter
      # @see Services::DeliverFormSubmissionNotificationsService
      def deliver_notification_for(scope:, the_thing:, repository: self, **keywords)
        notification_context = Parameters::NotificationContextParameter.new(scope: scope, the_thing: the_thing, **keywords)
        Services::DeliverFormSubmissionNotificationsService.call(notification_context: notification_context, repository: repository)
      end

      # Responsible for delivering notifications (i.e., email)
      # @param notification [String] Name of the notification
      # @param roles_for_recipients [Hash]
      # @param entity [String] The entity that is the "subject" of the notification
      # @option roles_for_recipients [Array<String>] :acting_as
      # @option roles_for_recipients [Array<String>] :cc role (names) to use to find associated emails to send as :cc
      # @option roles_for_recipients [Array<String>] :bcc role (names) to use to find associated emails to send as :to
      # @return [void]
      def send_notification_for_entity_trigger(notification:, entity:, repository: self, **roles_for_recipients)
        Services::Notifier.deliver(
          notification: notification,
          entity: entity,
          to: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:acting_as], repository: repository),
          cc: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:cc], repository: repository),
          bcc: convert_recipient_roles_to_email(entity: entity, roles: roles_for_recipients[:bcc], repository: repository)
        )
      end

      private

      def convert_recipient_roles_to_email(entity:, roles:, repository: self)
        return [] unless roles.present?
        repository.user_emails_for_entity_and_roles(entity: entity, roles: roles)
      end
    end
  end
end
