require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe SignoffOnBehalfOfForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id) }
        let(:base_options) { { work: work, processing_action_name: action, repository: repository } }

        subject { described_class.new(base_options) }

        its(:enrichment_type) { should eq('signoff_on_behalf_of') }
        its(:policy_enforcer) { should eq Policies::Processing::ProcessingEntityPolicy }

        it { should respond_to :work }

        let(:someone) { double(id: 'one') }

        before do
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:valid_on_behalf_of_collaborator_ids).and_return([someone.id])
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:valid_on_behalf_of_collaborators).and_return([someone])
          allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
            to receive(:on_behalf_of_collaborator).and_return(someone)
        end

        context 'validation' do
          it 'will require that someone be specified for approval' do
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
          end
          it 'will require that someone amongst the collaborators is specified' do
            subject = described_class.new(base_options.merge(on_behalf_of_collaborator_id: '__no_one__'))
            subject.valid?
            expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
          end
        end

        context '#render' do
          it 'will expose select box' do
            form_object = double('Form Object')
            expect(form_object).to receive(:input).with(:on_behalf_of_collaborator_id, collection: [someone], value_method: :id).
              and_return("<input />")
            expect(subject.render(f: form_object)).to eq("<input />")
          end
        end

        context 'valid submission' do
          let(:user) { double('User') }
          let(:signoff_service) { double('Signoff Service', call: true) }
          let(:on_behalf_of_collaborator) { double('Collaborator') }
          subject do
            described_class.new(
              base_options.merge(on_behalf_of_collaborator_id: 'someone_valid', signoff_service: signoff_service)
            )
          end
          before do
            allow(subject).to receive(:on_behalf_of_collaborator).and_return(on_behalf_of_collaborator)
            allow(subject).to receive(:valid?).and_return(true)
          end

          it 'will registered the action and related action' do
            expect(repository).to receive(:register_action_taken_on_entity).
              with(work: work, enrichment_type: 'signoff_on_behalf_of', requested_by: user, on_behalf_of: on_behalf_of_collaborator).
              and_call_original
            expect(repository).to receive(:register_action_taken_on_entity).with(
              work: work,
              enrichment_type: described_class::RELATED_ACTION_FOR_SIGNOFF,
              requested_by: user,
              on_behalf_of: on_behalf_of_collaborator
            ).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will log the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will call the signoff_service (because the logic is complicated)' do
            expect(signoff_service).to receive(:call).with(form: subject, requested_by: user, repository: repository)
            subject.submit(requested_by: user)
          end

          it 'will return the work' do
            expect(subject.submit(requested_by: user)).to eq(work)
          end
        end
      end
    end
  end
end
