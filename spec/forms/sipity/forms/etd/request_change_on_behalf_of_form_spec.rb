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
        let(:base_options) do
          {
            work: work,
            processing_action_name: action,
            repository: repository
          }
        end
        subject { described_class.new(base_options) }

        before do
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:valid_on_behalf_of_collaborator_ids).and_return([someone.id])
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:valid_on_behalf_of_collaborators).and_return([someone])
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:on_behalf_of_collaborator).and_return(someone)
        end

        its(:processing_action_name) { should eq(action.name) }
        its(:event_name) { should eq('etd/request_change_on_behalf_of_form/submit') }

        let(:someone) { double(id: 'one') }

        context 'validations' do
          it 'will require a comment' do
            subject = described_class.new(base_options.merge(comment: nil))
            subject.valid?
            expect(subject.errors[:comment]).to be_present
          end

          it 'will require an on_behalf_of_collaborator_id' do
            subject = described_class.new(base_options.merge(on_behalf_of_collaborator_id: nil))
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
          end

          it 'will requires a valid on_behalf_of_collaborator_id' do
            subject = described_class.new(base_options.merge(on_behalf_of_collaborator_id: someone.id * 2))
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
          end
        end

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
