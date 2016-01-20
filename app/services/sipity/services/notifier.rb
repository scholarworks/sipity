module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    module Notifier
      module_function

      # Providing a singular end point for sending messages
      def deliver(entity:, notification:, email_service_finder: default_email_service_finder, **options)
        notification_container = email_service_finder.call(entity: entity, notification: notification)
        deliver_email(notification_container: notification_container, notification: notification, options: options, entity: entity)
      end

      def default_email_service_finder
        Sipity::Mailers.method(:find_mailer_for)
      end
      private_class_method :default_email_service_finder

      def deliver_email(notification_container:, notification:, entity:, options:)
        to, cc, bcc = options.fetch(:to), options.fetch(:cc, []), options.fetch(:bcc, [])
        return notify_aibrake_of_no_sender if to.empty?
        email_notifier = notification_container.public_send(notification, entity: entity, to: to, cc: cc, bcc: bcc)
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
        alias call deliver
      end
    end
  end
end
