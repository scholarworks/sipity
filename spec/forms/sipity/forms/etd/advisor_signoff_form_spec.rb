require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe AdvisorSignoffForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: 'hello') }
        let(:user) { User.new(id: 1) }
        let(:signoff_service) { double('Signoff Service', call: true) }
        subject do
          described_class.new(work: work, processing_action_name: action, signoff_service: signoff_service, repository: repository)
        end

        context 'the default signoff service' do
          it 'will respond to :call' do
            expect(described_class.new(work: work, processing_action_name: action).send(:default_signoff_service)).to respond_to(:call)
          end
        end

        its(:work) { should eq work }
        its(:processing_action_name) { should eq action.name }
        it { should respond_to(:resulting_strategy_state) }

        context '#render' do
          it 'will render HTML safe submission terms and confirmation' do
            form_object = double('Form Object')
            expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
            expect(subject.render(f: form_object)).to be_html_safe
          end
        end

        its(:advisor_signoff_legend) { should be_html_safe }
        its(:signoff_agreement) { should be_html_safe }

        context 'validation' do
          it 'will require agreement to the signoff' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            subject.valid?
            expect(subject.errors[:agree_to_signoff]).to be_present
          end
        end

        context 'when not valid, #submit' do
          before do
            expect(subject).to receive(:valid?).and_return(false)
            expect(signoff_service).to_not receive(:call)
          end
          it 'will return the false' do
            expect(subject.submit(requested_by: user)).to eq(false)
          end
        end

        context 'when valid, #submit' do
          before do
            expect(subject).to receive(:valid?).and_return(true)
          end

          it 'will return the given work' do
            expect(subject.submit(requested_by: user)).to eq(work)
          end

          it 'will log the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will register that the given action was taken on the entity' do
            expect(repository).to receive(:register_action_taken_on_entity).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will call the AdvisorSignsOff service' do
            expect(signoff_service).to receive(:call)
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
