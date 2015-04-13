module Sipity
  module Models
    module Notification
      # Responsible for defining who receives what email and in what capacity
      # (eg to:, cc:, bcc:)
      class EmailRecipient < ActiveRecord::Base
        self.table_name = 'sipity_notification_email_recipients'
      end
    end
  end
end
