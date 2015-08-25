module Sipity
  module Models
    # Records when the identified entity has agreed to the existing terms of service.
    class AgreedToTermsOfService < ActiveRecord::Base
      self.table_name = :sipity_agreed_to_terms_of_services
      self.primary_key = :identifier_id
    end
  end
end
