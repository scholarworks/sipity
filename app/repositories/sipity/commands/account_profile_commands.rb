module Sipity
  module Commands
    # Responsible for issuing commands against the AccountProfile
    module AccountProfileCommands
      def update_user_preferred_name(user:, preferred_name:)
        user.update(name: preferred_name)
      end

      def user_agreed_to_terms_of_service(user:)
        user.update(agreed_to_terms_of_service: true)
      end
    end
  end
end
