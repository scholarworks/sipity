require 'spec_helper'
require 'sipity/controllers/work_submissions/show_presenter'

module Sipity
  module Controllers
    module WorkSubmissions
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:work_submission) { Models::Work.new(id: 'hello-world') }
        subject { described_class.new(context, work_submission: work_submission) }

        it 'exposes processing_state' do
          allow(work_submission).to receive(:processing_state).and_return('Hello')
          expect(subject.processing_state).to eq('Hello')
        end

        it 'will expose an overview_section' do
          expect(I18n).to receive(:t)
          subject.overview_section
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
      end
    end
  end
end
