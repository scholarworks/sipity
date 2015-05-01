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
          # TODO: Does this even make sense? It is not used outside of this
          # class. It was a presumptive change.
          its(:column_names) { should include('form_class_name') }
          its(:column_names) { should include('completion_required') }
          its(:column_names) { should include('action_type') }
          its(:column_names) { should include('allow_repeat_within_current_state') }
        end

        subject { described_class.new }
        it 'will raise an ArgumentError if you provide an invalid action_type' do
          expect { subject.action_type = '__incorrect_type__' }.to raise_error(ArgumentError)
        end

        context '#name' do
          it 'will convert the action name on write' do
            expect(described_class.new(name: :create?).name).to eq('new')
          end
        end

        its(:default_action_type) { should be_a(String) }

        context 'set action type' do
          it 'will set the action type if none is specified' do
            expect(subject.action_type).to be_present
          end

          it 'will set the action type if none is specified' do
            subject = described_class.new(resulting_strategy_state_id: 1)
            expect(subject.action_type).to eq(described_class::STATE_ADVANCING_ACTION)
          end
        end
      end
    end
  end
end
