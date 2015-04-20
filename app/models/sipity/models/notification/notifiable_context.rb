module Sipity
  module Models
    module Notification
      # A bridge for defining the "contexts" in which emails are sent.
      #
      # When an object enters a new state, we want to be able to define what are
      # the emails that should be sent.
      #
      # In Sipity this could be modeled by defining a NotifiableContext for a
      # StrategyState and Email.
      #
      # @example
      #   strategy = Sipity::Models::Processing::StrategyState.new
      #   email = Sipity::Models::Notification::Email.new
      #
      #   Sipity::Models::Notification::NotifiableContext.new(
      #     notifying_concern: strategy_state,
      #     reason_for_notification: 'on_enter',
      #     email: email
      #   )
      class NotifiableContext < ActiveRecord::Base
        self.table_name = 'sipity_notification_notifiable_contexts'
        belongs_to :notifying_concern, polymorphic: true
        belongs_to :email, class_name: 'Sipity::Models::Notification::Email'
      end
    end
  end
end
