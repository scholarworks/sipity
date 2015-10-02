require 'active_support/core_ext/array/wrap'

module Sipity
  module Services
    # Responsible for taking a notification context, building out the emails
    # and recipients that should receive notifications, then telling the
    # notifier to process those email requests.
    #
    # @note Appending the Service name to the class, because Rails likes to
    #   use the #classify and #constantize to return a singular version of the
    #   given string (i.e. "Pigs".classify == "Pig")
    class DeliverFormSubmissionNotificationsService
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(notification_context:, repository: notification_context.repository, notifier: default_notifier)
        self.notification_context = notification_context
        self.repository = repository
        self.notifier = notifier
      end

      delegate :scope, :the_thing, :reason, to: :notification_context
      private :scope, :the_thing

      def call
        role_names_with_email_addresses = repository.get_role_names_with_email_addresses_for(entity: the_thing)

        # Find all of the emails
        emails = repository.email_notifications_for(scope: scope, reason: reason)

        # Retrieve the email addresses associated with each of the roles

        # Then send each email
        emails.each do |email|
          deliverer.call(options_for_an_email_new(email: email, role_names_with_email_addresses: role_names_with_email_addresses))
        end
      end

      private

      attr_accessor :notification_context, :repository, :notifier

      def options_for_an_email_new(email:, role_names_with_email_addresses:)
        base_options = { notification: email.method_name, entity: the_thing, to: [], cc: [], bcc: [] }
        email.recipients.each do |recipient|
          role_names_with_email_addresses[recipient.role_name]
        end
      end

      def options_for_an_email(email)
        base_options = { notification: email.method_name, entity: the_thing, to: [], cc: [], bcc: [] }
        email.recipients.each { |recipient| append_recipient_options_to(base_options, recipient) }
        base_options
      end

      def append_recipient_options_to(base_options, recipient)
        recipient_strategy = recipient.recipient_strategy.to_sym
        emails = repository.user_emails_for_entity_and_roles(entity: the_thing, roles: recipient.role)
        base_options[recipient_strategy] += Array.wrap(emails) if emails.present?
        base_options
      end

      def default_notifier
        Services::Notifier
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
