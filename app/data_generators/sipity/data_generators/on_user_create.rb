module Sipity
  module DataGenerators
    # Responsible for adding user to registered user group
    #
    class OnUserCreate
      def self.call(user)
        new(user).call
      end

      def initialize(user)
        self.user = user
      end

      def call
        add_user_to_registered_group!
      end

      attr_reader :user

      private

      attr_writer :user

      def add_user_to_registered_group!
        all_registered_users_group = Sipity::Models::Group.find_or_create_by!(name: Models::Group::ALL_REGISTERED_USERS)
        all_registered_users_group.group_memberships.create(user: user) unless register_user.group_memberships.where(user: user)
      end
    end
  end
end
