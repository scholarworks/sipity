require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe RequestChangeOnBehalfOfForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: 'hello') }
        let(:user) { User.new(id: 1) }
        subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

        its(:processing_action_name) { should eq(action.name) }
        its(:event_name) { should eq('etd/request_change_on_behalf_of_form/submit') }

        context 'with valid data' do
          let(:a_processing_comment) { double }
          before do
            allow(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
            expect(subject).to receive(:valid?).and_return(true)
          end

          it 'will log the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
