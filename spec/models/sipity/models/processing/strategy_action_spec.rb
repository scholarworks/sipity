require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyAction, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('strategy_id') }
          its(:column_names) { should include('resulting_strategy_state_id') }
          its(:column_names) { should include('name') }
          its(:column_names) { should include('form_class_name') }
          its(:column_names) { should include('completion_required') }
          its(:column_names) { should include('action_type') }
        end

        subject { described_class.new }
        it 'will raise an ArgumentError if you provide an invalid action_type' do
          expect { subject.action_type = '__incorrect_type__' }.to raise_error(ArgumentError)
        end

        context 'set action type' do
          it 'will set the action type if none is specified' do
            expect(subject.action_type).to be_present
          end
        end
      end
    end
  end
end
