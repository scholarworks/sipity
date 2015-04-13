module Sipity
  module Models
    module Notification
      # Responsible for defining an email that is associated with a given
      # context; I believe the context is something that will be triggered via
      # an action however, I don't believe this needs to be a "hard"
      # relationship. It is instead a polymorphic relationship.
      class Email < ActiveRecord::Base
        self.table_name = 'sipity_notification_emails'
        has_many(
          :notifiable_contexts,
          dependent: :destroy,
          foreign_key: :email_id,
          class_name: 'Sipity::Models::Notification::NotifiableContext'
        )
        has_many(
          :recipients,
          dependent: :destroy,
          foreign_key: :email_id,
          class_name: 'Sipity::Models::Notification::EmailRecipient'
        )
      end
    end
  end
end
