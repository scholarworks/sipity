require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe SignoffOnBehalfOfForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id) }
        subject { described_class.new(work: work, repository: repository, processing_action_name: action) }

        its(:enrichment_type) { should eq('signoff_on_behalf_of') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }

        context 'validation' do
          before do
            allow(repository).to receive(:collaborators_that_can_advance_the_current_state_of).and_return(['someone'])
          end
          it 'will require that someone be specified for approval' do
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator]).to be_present
          end
          it 'will require that someone amongst the collaborators is specified' do
            subject = described_class.new(
              work: work, repository: repository, on_behalf_of_collaborator: '__no_one__', processing_action_name: action
            )
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator]).to be_present
          end
        end

        context '#render' do
          let(:collaborator) { Models::Collaborator.new(name: 'Hello World', id: 1) }
          before do
            allow(repository).to receive(:collaborators_that_can_advance_the_current_state_of).and_return([collaborator])
          end
          it 'will expose select box' do
            form_object = double('Form Object')
            expect(form_object).to receive(:input).with(:on_behalf_of_collaborator, collection: [collaborator], value_method: :id).and_return("<input />")
            expect(subject.render(f: form_object)).to eq("<input />")
          end
        end

        context 'valid submission' do
          let(:user) { double('User') }
          let(:signoff_service) { double('Signoff Service') }
          subject do
            described_class.new(
              work: work, processing_action_name: action, repository: repository, on_behalf_of_collaborator: 'someone_valid',
              signoff_service: signoff_service
            )
          end
          before { allow(subject).to receive(:valid?).and_return(true) }

          it 'will call the signoff_service (because the logic is complicated)' do
            expect(signoff_service).to receive(:call).with(form: subject, requested_by: user, repository: repository)
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
