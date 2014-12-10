require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Permission, type: :model do
      it 'belongs to a :user' do
        expect(described_class.reflect_on_association(:user)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'belongs to a :entity' do
        expect(described_class.reflect_on_association(:entity)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'relies on the database to enforce the requirement of an :role' do
        user = User.new(id: 1)
        entity = Models::Header.new(id: 1)
        expect { Permission.create!(user: user, entity: entity) }.
          to raise_error(ActiveRecord::StatementInvalid, /role may not be NULL/)
      end
    end
  end
end
