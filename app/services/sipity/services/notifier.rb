module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    class Notifier
      # Providing a singular end point for sending messages
      def self.deliver(options = {})
        notification_name = options.fetch(:notification)
        unless Sipity::Mailers::EmailNotifier.respond_to?(notification_name)
          fail Exceptions::NotificationNotFoundError
        end
        to = options.fetch(:to)
        cc = options.fetch(:cc) { [] }
        bcc = options.fetch(:bcc) { [] }
        entity = options.fetch(:entity)

        email_notifier = Sipity::Mailers::EmailNotifier.send(notification_name, entity: entity, to: to, cc: cc, bcc: bcc)
        email_notifier.deliver
      end
    end
  end
end
