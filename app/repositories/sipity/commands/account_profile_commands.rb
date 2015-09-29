module Sipity
  module Commands
    # Responsible for issuing commands against the AccountProfile
    module AccountProfileCommands
      def user_agreed_to_terms_of_service(user:, agreed_at: Time.zone.now)
        identifier_id = PowerConverter.convert(user, to: :identifier_id)
        Models::AgreedToTermsOfService.find_or_create_by(identifier_id: identifier_id) do |service|
          service.agreed_at = agreed_at
        end
      end
    end
  end
end
