require 'rails_helper'

module Sipity
  module Models
    RSpec.describe EventLog, type: :model do
      it 'belongs to a :user' do
        expect(described_class.reflect_on_association(:user)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'belongs to a :subject' do
        expect(described_class.reflect_on_association(:subject)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'relies on the database to enforce the requirement of an :event_name' do
        user = User.new(id: 1)
        entity = Models::Header.new(id: 1)
        expect { EventLog.create!(user: user, subject: entity) }.
          to raise_error(ActiveRecord::StatementInvalid, /event_name may not be NULL/)
      end
    end
  end
end
