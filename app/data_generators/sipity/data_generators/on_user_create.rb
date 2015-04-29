module Sipity
  module DataGenerators
    # Responsible for adding user to registered user group
    #
    class OnUserCreate
      def self.call(user)
        new(user: user).call
      end

      def initialize(user:)
        self.user = user
      end

      def call
        add_user_to_registered_group!
      end

      attr_reader :user

      private

      attr_writer :user

      def add_user_to_registered_group!
        registered_users_group = Sipity::Models::Group.find_or_create_by!(name: Models::Group::ALL_REGISTERED_USERS)
        registered_users_group.group_memberships.create(user: user) if registered_users_group.group_memberships.where(user: user).empty?
      end
    end
  end
end
