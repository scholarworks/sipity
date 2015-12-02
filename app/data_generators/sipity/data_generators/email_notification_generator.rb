require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module DataGenerators
    # Responsible for building the appropriate email generation
    class EmailNotificationGenerator
      def self.call(**keywords)
        new(**keywords).call
      end
      def initialize(strategy:, reason:, scope:, email_name:, recipients:)
        self.strategy = strategy
        self.reason = reason
        self.email_name = email_name
        self.recipients = recipients
        assign_scope(strategy: strategy, scope: scope, reason: reason)
      end

      def call
        email = persist_email
        assign_recipients_to(email: email)
        assign_scope_and_reason_to(email: email)
      end

      private

      def persist_email
        Models::Notification::Email.find_or_create_by!(method_name: email_name)
      end

      def assign_recipients_to(email:)
        recipients.slice(:to, :cc, :bcc).each do |(recipient_strategy, recipient_roles)|
          Array.wrap(recipient_roles).each do |role|
            email.recipients.find_or_create_by!(role: PowerConverter.convert_to_role(role), recipient_strategy: recipient_strategy.to_s)
          end
        end
      end

      def assign_scope_and_reason_to(email:)
        Models::Notification::NotifiableContext.find_or_create_by!(
          scope_for_notification: scope,
          reason_for_notification: reason,
          email: email
        )
      end

      attr_accessor :strategy, :reason, :email_name, :recipients
      attr_reader :scope

      # Note this is a rather hideous switch statement related to coercing data.
      def assign_scope(strategy:, scope:, reason:)
        @scope = begin
          case reason
          when Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
            Conversions::ConvertToProcessingAction.call(scope, scope: strategy)
          when Parameters::NotificationContextParameter::REASON_ENTERED_STATE
            PowerConverter.convert(scope, to: :strategy_state, scope: strategy)
          end
        end
      end
    end
  end
end
