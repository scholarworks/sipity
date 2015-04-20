module Sipity
  module Queries
    # Responsible for querying the notifications.
    module NotificationQueries
      def email_notifications_for(context:, concerning:)
        emails = Models::Notification::Email.arel_table
        notifiable_contexts = Models::Notification::NotifiableContext.arel_table
        Models::Notification::Email.where(
          emails[:id].in(
            notifiable_contexts.project(notifiable_contexts[:email_id]).where(
              notifiable_contexts[:notifying_concern_id].eq(concerning.id).and(
                notifiable_contexts[:notifying_concern_type].eq(Conversions::ConvertToPolymorphicType.call(concerning))
              ).and(
                notifiable_contexts[:notifying_context].eq(context)
              )
            )
          )
        ).includes(:recipients)
      end
    end
  end
end
