module Sipity
  module Models
    # Responsible for building the data structures used in sending
    # notifications.
    module Notification
      def self.table_name_prefix
        'sipity_notification_'
      end
    end
  end
end
