require 'rails_helper'
require 'sipity/models/event_log'

module Sipity
  module Models
    RSpec.describe EventLog, type: :model do

      it { should belong_to(:user) }
      it { should belong_to(:entity) }
      it { should belong_to(:requested_by) }

      # This is a "stop-gap" for validations going forward. Once the database
      # constraint is added this should go away.
      it { should validate_presence_of(:identifier_id).on(:create) }

      it 'relies on the database to enforce the requirement of an :event_name' do
        expect do
          EventLog.create!(identifier_id: '1', entity_id: '2', entity_type: 'Sipity::Models::Work')
        end.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
