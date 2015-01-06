module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    class Notifier
      # Providing a singular end point for sending messages
      def self.deliver(options = {})
        @notification_name = options.fetch(:notification)
        @to = options.fetch(:to)
        @cc = options.fetch(:cc) { [] }
        @bcc = options.fetch(:bcc) { [] }
      end
    end
  end
end
