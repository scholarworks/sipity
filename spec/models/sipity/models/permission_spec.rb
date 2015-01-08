require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Permission, type: :model do
      it 'belongs to a :actor' do
        expect(described_class.reflect_on_association(:actor)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'belongs to a :entity' do
        expect(described_class.reflect_on_association(:entity)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'relies on the database to enforce the requirement of an :acting_as' do
        user = User.new(id: 1)
        entity = Models::Sip.new(id: 1)
        expect { Permission.create!(actor: user, entity: entity) }.
          to raise_error(ActiveRecord::StatementInvalid, /acting_as may not be NULL/)
      end
    end
  end
end
