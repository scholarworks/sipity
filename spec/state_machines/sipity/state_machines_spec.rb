require 'spec_helper'
require 'sipity/state_machines'

module Sipity
  RSpec.describe StateMachines::Interface do
    let(:entity) { Models::Work.new(work_type: 'etd') }
    let(:user) { double('user') }
    let(:repository) { double('repository') }
    it 'exposes the .trigger! interface' do
      expect(StateMachines::Interface.trigger!(entity: entity, user: user, repository: repository, event_name: 'submit_for_review')).
        to_not have_failed
    end
  end
  RSpec.describe StateMachines do
    context '.trigger! (public API)' do
      let(:entity) { Models::Work.new(work_type: 'etd') }
      let(:user) { double('user') }
      let(:repository) { double('repository') }
      let(:builder) { double('Builder', new: builder) }
      let(:state_machine) { double('State Machine') }
      it 'will instantiate the workflow and trigger the event' do
        allow(described_class).to receive(:find_state_machine_for).and_call_original
        expect_any_instance_of(StateMachines::EtdStateMachine).to receive(:trigger!).with(:submit_for_review, {})
        described_class.trigger!(entity: entity, user: user, repository: repository, event_name: 'submit_for_review')
      end
    end

    context '.available_event_triggers_for' do
      let(:user) { double('user') }
      let(:repository) { double('repository', user_can_act_as_the_following_on_entity: 'creating_user') }
      let(:entity) { Models::Work.new(work_type: 'etd', processing_state: 'new') }
      it 'will return an array of strings' do
        # TODO: This is a test coupled to the behavior of an existing state diagram.
        actual = described_class.available_event_triggers_for(user: user, entity: entity, repository: repository)
        expect(actual).to eq(["update", "show", "delete", "submit_for_review"])
      end
    end

    context '.state_diagram_for' do
      let(:valid_work_type) { 'etd' }
      context 'with valid enrichment type' do
        subject { described_class.state_diagram_for(work_type: valid_work_type) }
        it { should be_a(StateMachines::StateDiagram) }
        it { should eq(StateMachines::EtdStateMachine.state_diagram) }
      end
    end

    context '.find_state_machine_for' do
      let(:valid_work_type) { 'etd' }
      let(:invalid_work_type) { '__very_much_not_valid__' }
      context 'with valid enrichment type' do
        subject { described_class.find_state_machine_for(work_type: valid_work_type) }
        it { should respond_to(:new) }
        it { should eq(StateMachines::EtdStateMachine) }
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
