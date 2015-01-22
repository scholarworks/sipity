require 'rails_helper'

module Sipity
  module Models
    RSpec.describe EventLog, type: :model do
      it 'belongs to a :user' do
        expect(described_class.reflect_on_association(:user)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'belongs to a :entity' do
        expect(described_class.reflect_on_association(:entity)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'relies on the database to enforce the requirement of an :event_name' do
        expect { EventLog.create!(user_id: '1', entity_id: '2', entity_type: 'Sipity::Models::Work') }.
          to raise_error(ActiveRecord::StatementInvalid, /event_name may not be NULL/)
      end
    end
  end
end
