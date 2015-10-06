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

      def initialize(notification_context:, repository: default_repository, notifier: default_notifier)
        self.notification_context = notification_context
        self.repository = repository
        self.notifier = notifier
      end

      delegate :scope, :the_thing, :reason, to: :notification_context
      private :scope, :the_thing

      def call
        role_names_with_email_addresses = repository.get_role_names_with_email_addresses_for(entity: the_thing)
        repository.email_notifications_for(scope: scope, reason: reason).each do |email|
          notifier.call(options_for_an_email_new(email: email, role_names_with_email_addresses: role_names_with_email_addresses))
        end
      end

      private

      attr_accessor :notification_context, :repository, :notifier

      def options_for_an_email_new(email:, role_names_with_email_addresses:)
        # Passing the repository along as we may have cached information from Cogitate
        base_options = { notification: email.method_name, entity: the_thing, to: [], cc: [], bcc: [], repository: repository }
        email.recipients.each do |recipient|
          base_options[recipient.recipient_strategy.to_sym] ||= []
          base_options[recipient.recipient_strategy.to_sym] += role_names_with_email_addresses.fetch(recipient.role_name) { [] }
        end
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
