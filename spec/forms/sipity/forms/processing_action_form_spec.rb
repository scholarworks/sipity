require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe ProcessingActionForm do
      let(:work) { Models::Work.new(id: '1234') }
      let(:repository) { CommandRepositoryInterface.new }
      subject { described_class.new(work: work, repository: repository) }

      its(:policy_enforcer) { should eq Policies::Processing::ProcessingEntityPolicy }
      its(:to_key) { should be_empty }
      its(:to_param) { should be_nil }
      its(:persisted?) { should eq(false) }
      its(:to_model) { should eq(work) }
      its(:render) { should be_nil }

      context 'the processing entity vs. "entity" differentiation' do
        let(:strategy) { Models::Processing::Strategy.new(id: 1) }
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: strategy.id, strategy: strategy) }
        before do
          allow(work).to receive(:to_processing_entity).and_return(processing_entity)
        end
        its(:to_processing_entity) { should eq(processing_entity) }
        its(:strategy) { should eq(processing_entity.strategy) }
        its(:strategy_id) { should eq(processing_entity.strategy_id) }
        its(:work_type) { should eq('doctoral_dissertation') }
      end

      it 'will require subclasses to implement their :enrichment_type' do
        expect { subject.enrichment_type }.to raise_error(NotImplementedError)
      end

      context 'validations' do
        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end
      end

      context '#submit' do
        let(:user) { double('User') }
        context 'with invalid data' do
          before do
            expect(subject).to receive(:valid?).and_return(false)
          end
          it 'will return false if not valid' do
            expect(subject.submit(requested_by: user)).to eq(false)
          end
          it 'will not attempt to save the form' do
            expect(subject).to_not receive(:save)
            subject.submit(requested_by: user)
          end
        end

        context 'with valid data' do
          before do
            expect(subject).to receive(:valid?).and_return(true)
            expect(subject).to receive(:enrichment_type).and_return('__not_implemented__')
          end

          it 'will set the registered_action' do
            the_registered_action = double
            allow(repository).to receive(:register_action_taken_on_entity).and_return(the_registered_action)
            expect { subject.submit(requested_by: user) }.
              to change { subject.registered_action }.from(nil).to(the_registered_action)
            expect(subject.to_registered_action).to eq(the_registered_action)
          end

          it 'will return the work' do
            returned_value = subject.submit(requested_by: user)
            expect(returned_value).to eq(work)
          end

          it "will transition the work's corresponding enrichment todo item to :done" do
            expect(repository).to receive(:register_action_taken_on_entity).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will record the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
