require 'spec_helper'
require 'support/sipity/command_repository_interface'

module Sipity
  module Services
    RSpec.describe AdvisorSignsOff do
      let(:form) { double('Form', to_processing_action: action, processing_action_name: 'hello', entity: double('Entity', strategy_id: 1)) }
      let(:action) { double('Action', resulting_strategy_state: 'chubacabra', strategy_id: 1) }
      let(:another_action) { double('AnotherAction', to_processing_action: double(strategy_id: 1)) }
      let(:on_behalf_of) { double('Collaborator') }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { double('User') }

      subject do
        described_class.new(
          form: form, repository: repository, requested_by: requested_by, on_behalf_of: on_behalf_of, also_register_as: another_action
        )
      end

      it 'will default the on_behalf_of to the requested_by if none is given' do
        subject = described_class.new(form: form, repository: repository, requested_by: requested_by)
        expect(subject.on_behalf_of).to eq(requested_by)
      end

      context '.call' do
        it 'is a wrapper' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(form: form, repository: repository, requested_by: requested_by)
        end
      end

      context 'when there are other advisors that have not yet signed-off' do
        before { expect(subject).to receive(:last_advisor_to_signoff?).and_return(false) }
        it 'will NOT change the processing state' do
          expect(repository).to_not receive(:update_processing_state!)
          subject.call
        end
        it 'will log the event, register the action, and send an email to the creating user' do
          expect(repository).to receive(:register_action_taken_on_entity).
            with(
              entity: form.entity,
              action: form.to_processing_action,
              requested_by: requested_by,
              on_behalf_of: on_behalf_of,
              also_register_as: another_action
            )
          subject.call
        end
      end

      context 'when this is the last advisor to signoff' do
        before { expect(subject).to receive(:last_advisor_to_signoff?).and_return(true) }
        it 'will change the processing state' do
          expect(repository).to receive(:update_processing_state!).and_call_original
          subject.call
        end
        it 'will log the event, register the action, and send an email to the creating user' do
          expect(repository).to receive(:register_action_taken_on_entity).
            with(
              entity: form.entity,
              action: form.to_processing_action,
              requested_by: requested_by,
              on_behalf_of: on_behalf_of,
              also_register_as: another_action
            )
          subject.call
        end
      end

      # Even though this is a private method I want to verify my personal logic.
      context '#last_advisor_to_signoff?' do
        [
          { reviewers: ['bob'], already_reviewed: ['alice'], expected: false },
          { reviewers: ['alice'], already_reviewed: ['alice'], expected: true },
          { reviewers: ['alice', 'bob'], already_reviewed: ['alice'], expected: false },
          { reviewers: ['alice', 'bob'], already_reviewed: ['alice', 'bob'], expected: true },
          { reviewers: ['carol', 'bob'], already_reviewed: ['alice', 'bob'], expected: false },
          { reviewers: [], already_reviewed: ['alice', 'bob'], expected: true },
          { reviewers: [], already_reviewed: [], expected: true },
          { reviewers: ['bob'], already_reviewed: [], expected: false }
        ].each_with_index do |example, index|
          it "will handle #{example.inspect} (Scenario ##{index})" do
            expect(repository).to receive(:work_collaborators_responsible_for_review).
              and_return(example.fetch(:reviewers))
            expect(repository).to receive(:collaborators_that_have_taken_the_action_on_the_entity).
              and_return(example.fetch(:already_reviewed))
            expect(subject.send(:last_advisor_to_signoff?)).to eq(example.fetch(:expected))
          end
        end
      end

      its(:default_repository) { is_expected.to respond_to :collaborators_that_have_taken_the_action_on_the_entity }
      its(:default_repository) { is_expected.to respond_to :work_collaborators_responsible_for_review }
      its(:default_action) { is_expected.to eq(form.to_processing_action) }
      its(:default_also_register_as) { is_expected.to be_empty }
    end
  end
end
