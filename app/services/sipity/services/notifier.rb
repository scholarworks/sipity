module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    module Notifier
      module_function

      # Providing a singular end point for sending messages
      def deliver(repository:, notification:, notification_container: default_notification_container, **options)
        notification_container = build_verified_notification_container(
          notification_container: notification_container, notification: notification
        )
        deliver_email(repository: repository, notification_container: notification_container, notification: notification, options: options)
      end

      def build_verified_notification_container(notification:, notification_container:)
        return notification_container if notification_container.respond_to?(notification)
        fail Exceptions::NotificationNotFoundError, name: notification, container: notification_container
      end
      private_class_method :build_verified_notification_container

      def default_notification_container
        Sipity::Mailers::EmailNotifier
      end
      private_class_method :default_notification_container

      def deliver_email(repository:, notification_container:, notification:, options:)
        to, cc, bcc = options.fetch(:to), options.fetch(:cc, []), options.fetch(:bcc, [])
        entity = options.fetch(:entity)
        return notify_aibrake_of_no_sender if to.empty?
        email_notifier = notification_container.public_send(notification, entity: entity, to: to, cc: cc, bcc: bcc, repository: repository)
        email_notifier.deliver_now
      end
      private_class_method :deliver_email

      def notify_aibrake_of_no_sender
        Airbrake.notify_or_ignore(
          error_class: Exceptions::SenderNotFoundError,
          error_message: "#{Exceptions::SenderNotFoundError}: Return without sending message.",
          parameters: {}
        )
        false
      end
      private_class_method :notify_aibrake_of_no_sender

      class << self
        alias_method :call, :deliver
      end
    end
  end
end
