module Sipity
  module Services
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
        registered_users_group = Sipity::Models::Group.all_registered_users
        registered_users_group.group_memberships.create(user: user) if registered_users_group.group_memberships.where(user: user).empty?
      end
    end
  end
end
