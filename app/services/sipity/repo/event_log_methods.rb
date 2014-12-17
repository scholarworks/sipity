module Sipity
  module Repo
    # Methods that are helpful for querying the event log
    module EventLogMethods
      # @param [Hash] options for conditional querying of the event log.
      # @option options [User] :user; If given, what events were taken by the user
      # @option options [Entity] :entity; If given, what events happened to the entity.
      def sequence_of_events_for(options = {})
        event_log_model.where(options.slice(:entity, :user)).order(created_at: :desc)
      end

      # REVIEW: This knowledge is repeated through out the various methods. How
      #   to resolve this as it relates to module mixins. The Repository object
      #   is becoming a bit of a god class. How to tease apart those concerns?
      #   One consideration is that within the constraints of the Repository
      #   it is acceptable to reference other classes.
      def log_event!(entity:, user:, event_name:)
        event_log_model.create!(entity: entity, user: user, event_name: event_name)
      end

      private

      # REVIEW: Does this make sense? Would I create a module that has all of
      #   the models as represented by methods?
      def event_log_model
        Models::EventLog
      end
    end
  end
end
