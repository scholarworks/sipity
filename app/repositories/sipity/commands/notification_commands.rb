module Sipity
  # :nodoc:
  module Commands
    # Commands
    module NotificationCommands
      # Responsible for delivering notifications (i.e. emails)
      # @param scope [Object]
      # @param the_thing [Object] what are you going to be building most of the email content from?
      # @param keywords [Hash] additional keywords; See Sipity::Parameters::NotificationContextParameter
      # @return [void]
      #
      # @see Parameters::NotificationContextParameter
      # @see Services::DeliverFormSubmissionNotificationsService
      def deliver_notification_for(scope:, the_thing:, repository: self, **keywords)
        notification_context = Parameters::NotificationContextParameter.new(scope: scope, the_thing: the_thing, **keywords)
        Services::DeliverFormSubmissionNotificationsService.call(notification_context: notification_context, repository: repository)
      end
    end
  end
end
