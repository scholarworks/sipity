module Sipity
  module RepositoryMethods
    # Responsible for coordinating with the notification layer.
    # What is the notification layer? Don't know yet. But I suspect it will
    # be us sending various emails to recipients.
    module NotificationMethods
      def send_notification_for_entity_trigger(notification:, entity:, to_roles:)
        # These instance variables are not needed; But to appeas Rubocop I'm
        # using them.
        @notification, @entity, @to_roles = notification, entity, to_roles
        @to = convert_entity_and_roles_to_email_recipients(roles: to_roles, entity: entity)
      end

      private

      # Responsible for extracting the emails of people with the given role
      # for the given entity. Note, a role is not a group.
      def convert_entity_and_roles_to_email_recipients(roles:, entity:)
        @entity, @to_roles = roles, entity
      end
    end
    private_constant :NotificationMethods
  end
end
