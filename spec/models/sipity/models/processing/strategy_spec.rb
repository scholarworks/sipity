require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe Strategy, type: :model do
        subject { described_class }
        its(:column_names) { should include('proxy_for_id') }
        its(:column_names) { should include('proxy_for_type') }
        its(:column_names) { should include('name') }

        context '#initial_strategy_state' do
          subject { described_class.new(proxy_for_id: 1, proxy_for_type: 'A Type', name: 'ETD Workflow') }
          it 'will create a state if one does not exist' do
            subject.save!
            expect { subject.initial_strategy_state }.
              to change { subject.strategy_states.count }.by(1)
          end
        end
      end
    end
  end
end
