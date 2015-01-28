require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe WorkEventTriggerPolicy do
      let(:user) { User.new(id: 123) }
      let(:work) { Models::Work.new(id: 123, work_type: 'etd', processing_state: 'new') }
      let(:event_name) { 'approve_for_ingest' }
      let(:repository) do
        double('Repository', are_all_of_the_required_todo_items_done_for_work?: true, can_the_user_act_on_the_entity?: true)
      end
      # TODO: Disentangle the ETD State Machine
      let(:state_diagram) do
        StateMachines::StateDiagram.new('new' => { submit_for_review?: 'creating_user' })
      end
      let(:form) { double('Form', work: work, event_name: event_name, state_diagram: state_diagram) }
      subject { described_class.new(user, form, repository: repository) }

      context 'initialization' do
        it 'fails if the form does not have a work' do
          form = double
          expect { described_class.new(user, form) }.to raise_error Exceptions::PolicyEntityExpectationError
        end

        it 'fails if the form does not have a work' do
          work = double('Work')
          form = double(work: work, event_name: event_name)
          expect { described_class.new(user, form) }.to raise_error Exceptions::PolicyEntityExpectationError
        end
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for a non-persisted entity' do
        its(:submit?) { should eq(false) }
      end

      context 'for a user and persisted entity' do
        before { expect(work).to receive(:persisted?).and_return(true) }
        context 'and an invalid event trigger' do
          its(:submit?) { should eq(false) }
        end

        context 'and not all required todo items are complete' do
          before do
            expect(repository).to receive(:can_the_user_act_on_the_entity?).and_return(false)
          end
          let(:event_name) { 'submit_for_review' }
          its(:submit?) { should eq(false) }
        end

        context 'and event triggered by user without access' do
          before do
            expect(repository).to receive(:can_the_user_act_on_the_entity?).and_return(false)
          end
          let(:event_name) { 'submit_for_review' }
          its(:submit?) { should eq(false) }
        end

        context 'and event is triggered by user with access' do
          let(:event_name) { 'submit_for_review' }
          its(:submit?) { should eq(true) }
        end
      end
    end
  end
end
