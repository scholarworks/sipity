module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    module Notifier
      module_function

      # Providing a singular end point for sending messages
      def deliver(options = {})
        notificaton_container = build_notification_container(options.slice(:notificaton_container, :notification))
        deliver_email(notificaton_container: notificaton_container, notification: options.fetch(:notification), options: options)
      end

      def build_notification_container(notification:, notificaton_container: Sipity::Mailers::EmailNotifier)
        unless notificaton_container.respond_to?(notification)
          fail Exceptions::NotificationNotFoundError, name: notification, container: notificaton_container
        end
        notificaton_container
      end
      private_class_method :build_notification_container

      def deliver_email(notificaton_container:, notification:, options:)
        to = options.fetch(:to)
        cc = options.fetch(:cc) { [] }
        bcc = options.fetch(:bcc) { [] }
        entity = options.fetch(:entity)
        if to.empty?
          Airbrake.notify_or_ignore(
            error_class: Exceptions::SenderNotFoundError,
            error_message: "#{Exceptions::SenderNotFoundError}: Return without sending message.",
            parameters: {}
          )
          return
        end
        email_notifier = notificaton_container.public_send(notification, entity: entity, to: to, cc: cc, bcc: bcc)
        email_notifier.deliver_now
      end

      private_class_method :deliver_email

      class << self
        alias_method :call, :deliver
      end
    end
  end
end
