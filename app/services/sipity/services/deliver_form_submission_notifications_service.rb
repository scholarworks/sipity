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

      delegate :action, :the_thing, :notifying_context, to: :notification_context
      private :action, :the_thing

      def call
        repository.email_notifications_for(concerning: action, context: notifying_context).each do |email|
          notifier.call(options_for_an_email(email))
        end
      end

      private

      attr_accessor :notification_context, :repository, :notifier

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
