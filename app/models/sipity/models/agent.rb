module Sipity
  module Models
    # A token representation of something that could take action on Sipity.
    class Agent < ActiveRecord::Base
      self.table_name = 'sipity_agents'
      devise :token_authenticatable, :trackable

      has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
      has_many :event_logs, class_name: 'Sipity::Models::EventLog', as: :requested_by

      # @note - This is not a service function because its isolated in its
      #   behavior and its not something that is going to be used all that
      #   often.
      def self.create_a_named_agent!(name:, authentication_token: self.authentication_token)
        create!(name: name, authentication_token: authentication_token)
      end
    end
  end
end
