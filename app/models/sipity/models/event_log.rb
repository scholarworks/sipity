module Sipity
  module Models
    # A place to record the named event for the given entity that was trigger by
    # a user's action.
    #
    # @note Where are the validations? They are enforced on the database.
    class EventLog < ActiveRecord::Base
      self.table_name = 'sipity_event_logs'
      belongs_to :entity, polymorphic: true

      # This is a "stop-gap" for validations going forward. Once the database
      # constraint is added this should go away.
      validates :identifier_id, presence: true, on: :create
    end
  end
end
