require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module DataGenerators
    # Responsible for persisting the email configuration in a consistent manner.
    # When does an email get sent, what is the template, and who receives those emails.
    class EmailNotificationGenerator
      # @api public
      def self.call(strategy:, reason:, scope:, email_name:, recipients:)
        new(strategy: strategy, reason: reason, scope: scope, email_name: email_name, recipients: recipients).call
      end

      # @param strategy [Sipity::Models::Processing::Strategy] The containing strategy for this email; Without the strategy the scope is
      #                                                        meaningless
      # @param reason [#to_s] Why is this email being sent? Did we enter a state? Was an action taken?
      # @param scope [Object] The specific name (or object) of associated with the reason (i.e. "submit_for_review" would be the scope)
      # @param email_name [#to_s] The template/method name for sending emails
      # @param recipients [Hash] With keys of :to, :cc, :bcc
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
            email.recipients.find_or_create_by!(role: PowerConverter.convert(role, to: :role), recipient_strategy: recipient_strategy.to_s)
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
          when Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED
            # A processing hook is associated with an action; However if I
            # wanted a notification when the action was taken, I would have
            # chosen a different reason. So instead consider that I need
            # some other pivot point; the strategy state makes logical sense.
            PowerConverter.convert(scope, to: :strategy_state, scope: strategy)
          end
        end
      end
    end
  end
end
