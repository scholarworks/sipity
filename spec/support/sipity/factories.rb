module Sipity
  module Factories
    def create_user(overrides = {})
      skip_agreed_to_tos = overrides.delete(:skip_agreed_to_tos) || false
      attributes = { name: 'Test User', email: 'test@example.com' }.merge(overrides)
      attributes[:username] ||= attributes[:email]
      User.create!(attributes).tap do |user|
        break if skip_agreed_to_tos
        require 'cogitate/client'
        identifier_id = Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: user.username)
        Sipity::Models::AgreedToTermsOfService.create!(identifier_id: identifier_id, agreed_at: Time.zone.now)
      end
    end
    module_function :create_user
  end
end
