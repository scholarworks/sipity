require 'spec_helper'
require 'sipity/state_machines'

module Sipity
  RSpec.describe StateMachines do
    context '#find_state_machine_for' do
      let(:valid_work_type) { 'etd' }
      let(:invalid_work_type) { '__very_much_not_valid__' }
      context 'with valid enrichment type' do
        subject { described_class.find_state_machine_for(work_type: valid_work_type) }
        it { should respond_to(:trigger!) }
      end
      context 'with invalid enrichment type' do
        it 'will raise an exception' do
          expect { described_class.find_state_machine_for(work_type: invalid_work_type) }.
            to raise_error(Exceptions::StateMachineNotFoundError)
        end
      end
    end
  end
end
