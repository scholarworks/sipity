require "rails_helper"
require 'sipity/data_generators/state_machine_generator'

module Sipity
  RSpec.describe DataGenerators::StateMachineGenerator do
    let(:processing_strategy) { Sipity::Models::Processing::Strategy.create!(name: 'hello') }
    let(:action_name) { 'do_it' }
    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(processing_strategy: processing_strategy, action_name: action_name, config: {})
    end

    let(:config) do
      {
        states: {
          pending_student_completion: { roles: ['creating_user'] },
          pending_advisor_completion: { roles: ['advising'] }
        },
        transition_to: :under_review,
        emails: { confirmation_of_submitted_to_ulra_committee: { to: 'creating_user', cc: 'advising' } },
        required_actions: [:attach, :plan_of_study, :publisher_information, :research_process, :faculty_response]
      }
    end

    context '#call' do
      subject { described_class.new(processing_strategy: processing_strategy, action_name: action_name, config: config) }
      it 'will generate the various data entries (but only once)' do
        expect do
          expect do
            expect do
              subject.call
            end.to change { Models::Notification::Email.count }
          end.to change { Models::Processing::StrategyActionPrerequisite.count }
        end.to change { Models::Processing::StrategyAction.count }

        # It can be called repeatedly without updating things
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        subject.call
      end
    end
  end
end
