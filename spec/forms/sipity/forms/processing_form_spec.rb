require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe ProcessingForm do
      let(:entity) { double }
      let(:form) { double(entity: entity, base_class: Models::Work, valid?: true, save: true, class: double(name: 'StartForm')) }
      let(:repository) { CommandRepositoryInterface.new }
      let(:user) { double }
      subject { described_class.new(form: form, repository: repository) }

      context 'configuration methods' do
        subject { described_class }
        its(:delegate_method_names) { should be_a(Array) }
        its(:private_delegate_method_names) { should be_a(Array) }
      end

      it { should delegate_method(:valid?).to(:form) }

      its(:default_repository) { should respond_to :register_processing_action_taken_on_entity }
      its(:default_repository) { should respond_to :log_event! }
      it { should respond_to :to_registered_action }

      it 'should convert the underlying entity to a processing entity' do
        expect(Conversions::ConvertToProcessingEntity).to receive(:call).with(entity).and_return(:converted)
        expect(subject.to_processing_entity).to eq(:converted)
      end

      it 'should convert the underlying entity to a work area' do
        expect(PowerConverter).to receive(:convert_to_work_area).with(entity).and_return(:converted)
        expect(subject.to_work_area).to eq(:converted)
      end

      context '#submit' do
        context 'when invalid' do
          before { allow(form).to receive(:valid?).and_return(false) }
          it 'will return false' do
            expect(subject).to_not receive(:save)
            expect(subject.submit(requested_by: user)).to be_falsey
          end
        end

        context 'when valid' do
          before { allow(form).to receive(:valid?).and_return(true) }
          it 'will return the underlying entity' do
            expect(form).to receive(:save).with(requested_by: user)
            expect(subject.submit(requested_by: user)).to eq(entity)
          end

          it 'will register the action that was taken' do
            expect(repository).to receive(:register_processing_action_taken_on_entity).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will log the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will set the registered action for future reference' do
            expect(repository).to receive(:register_processing_action_taken_on_entity).and_return(:registered_action)
            expect { subject.submit(requested_by: user) }.to change { subject.registered_action }.from(nil).to(:registered_action)
          end
        end
      end
    end
  end
end
