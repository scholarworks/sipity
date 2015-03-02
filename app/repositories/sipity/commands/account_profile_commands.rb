module Sipity
  module Commands
    # Responsible for issuing commands against the AccountProfile
    module AccountProfileCommands
      def update_user_preferred_name(user:, preferred_name:)
        user.update(name: preferred_name)
      end
    end
  end
end
