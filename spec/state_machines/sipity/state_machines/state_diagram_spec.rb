require 'spec_helper'

module Sipity
  module StateMachines
    RSpec.describe StateDiagram do
      let(:data_structure) do
        {
          'new' => {
            delete?: ['creating_user'], submit_for_review?: ['creating_user']
          }
        }
      end

      [
        nil,
        { 'valid' => 'invalid' },
        { 'valid' => { 'invalid?' => [] } },
        { 'valid' => { 'invalid' => [] } },
        { 'valid' => { :valid? => :invalid } },
        { 'valid' => { :valid? => [:invalid, 'valid'] } },
        'invalid?',
        { 'invalid?' => {} },
        { invalid: {} }
      ].each_with_index do |malformed, index|
        it "will not initialize scenario ##{index}" do
          expect { described_class.new(malformed) }.to raise_error(Exceptions::InvalidStateDiagramRawStructure)
        end
      end

      context '#available_event_triggers' do
        subject { described_class.new(data_structure) }
        it 'will return an array of ActionAvailability items' do
          expect(subject.available_event_triggers(current_state: 'new')).to eq(
            [
              subject.event_trigger_availability(current_state: 'new', event_name: 'delete'),
              subject.event_trigger_availability(current_state: 'new', event_name: 'submit_for_review')
            ]
          )
        end
      end

      context '#event_trigger_availability' do
        let(:state_diagram) { described_class.new(data_structure) }

        context 'given a valid current_state' do
          subject { state_diagram.event_trigger_availability(current_state: 'new', event_name: 'submit_for_review') }
          its(:acting_as) { should eq(['creating_user']) }
          its(:current_state) { should eq('new') }
          its(:event_name) { should eq('submit_for_review') }
        end

        context 'given an invalid current_state' do
          subject { state_diagram.event_trigger_availability(current_state: '__invalid__', event_name: 'submit_for_review') }
          its(:acting_as) { should eq([]) }
          its(:current_state) { should eq('__invalid__') }
          its(:event_name) { should eq('submit_for_review') }
        end

        context 'given an invalid event_name' do
          subject { state_diagram.event_trigger_availability(current_state: 'new', event_name: 'mangle_the_data') }
          its(:acting_as) { should eq([]) }
          its(:current_state) { should eq('new') }
          its(:event_name) { should eq('mangle_the_data') }
        end
      end
    end
  end
end
