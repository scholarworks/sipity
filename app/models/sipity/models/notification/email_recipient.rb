module Sipity
  module Models
    module Notification
      # Responsible for defining who receives what email and in what capacity
      # (eg to:, cc:, bcc:)
      class EmailRecipient < ActiveRecord::Base
        self.table_name = 'sipity_notification_email_recipients'
        belongs_to :email, class_name: 'Sipity::Models::Notification::Email'
        belongs_to :role, class_name: 'Sipity::Models::Role'

        enum(
          recipient_strategy: {
            'to' => 'to',
            'cc' => 'cc',
            'bcc' => 'bcc'
          }
        )
      end
    end
  end
end
