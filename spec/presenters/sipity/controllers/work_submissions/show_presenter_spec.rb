require 'spec_helper'
require 'sipity/controllers/work_submissions/show_presenter'

module Sipity
  module Controllers
    module WorkSubmissions
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
        let(:current_user) { double('Current User') }
        let(:work_submission) { Models::Work.new(id: 'hello-world') }
        subject { described_class.new(context, work_submission: work_submission) }

        it 'exposes processing_state' do
          allow(work_submission).to receive(:processing_state).and_return('Hello')
          expect(subject.processing_state).to eq('Hello')
        end

        context '#render_enrichment_action_set' do
          it 'will render the partial if there are elements' do
            action_set = double(present?: true)
            expect_any_instance_of(ComposableElements::ProcessingActionsComposer).
              to receive(:enrichment_action_set_for).with(identifier: 'required').and_return(action_set)
            expect(context).to receive(:render).with(partial: "enrichment_action_set", object: action_set)
            subject.render_enrichment_action_set('required')
          end
          it 'will render the partial if there are elements' do
            action_set = double(present?: false)
            expect_any_instance_of(ComposableElements::ProcessingActionsComposer).
              to receive(:enrichment_action_set_for).with(identifier: 'required').and_return(action_set)
            expect(context).to_not receive(:render)
            subject.render_enrichment_action_set('required')
          end
        end

        it 'will expose #section that accepts an identifier' do
          expect(I18n).to receive(:t)
          subject.section('overview')
        end

        context '#label' do
          it "will delegate to the work_submission's human_attribute_name" do
            expect(subject.label(:title)).to eq('Title')
          end
        end

        it 'will compose actions for the submission window' do
          expect(ComposableElements::ProcessingActionsComposer).to receive(:new).
            with(user: current_user, entity: work_submission)
          subject
        end

        it 'exposes resourceful_actions' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:resourceful_actions)
          subject.resourceful_actions
        end

        it 'exposes resourceful_actions?' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:resourceful_actions?)
          subject.resourceful_actions?
        end

        it 'exposes state_advancing_actions' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:state_advancing_actions)
          subject.state_advancing_actions
        end

        it 'exposes state_advancing_actions?' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:state_advancing_actions?)
          subject.state_advancing_actions?
        end

        it 'exposes enrichment_actions' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:enrichment_actions)
          subject.enrichment_actions
        end

        it 'exposes enrichment_actions?' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:enrichment_actions?)
          subject.enrichment_actions?
        end

        it 'exposes can_advance_processing_state?' do
          expect_any_instance_of(ComposableElements::ProcessingActionsComposer).to receive(:can_advance_processing_state?)
          subject.can_advance_processing_state?
        end
      end
    end
  end
end
