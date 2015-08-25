require 'cogitate/models/identifier'
class AddAgreeToTermsOfService < ActiveRecord::Migration
  def self.up
    User.where(agreed_to_terms_of_service: true).find_each do |user|
      identifier_id = PowerConverter.convert(user, to: :identifier_id)
      agreement = Sipity::Models::AgreedToTermsOfService.find_or_initialize_by(identifier_id: identifier_id)
      agreement.agreed_at = user.created_at
      agreement.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
