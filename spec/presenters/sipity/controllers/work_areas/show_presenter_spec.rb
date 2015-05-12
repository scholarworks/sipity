require 'spec_helper'
require 'sipity/controllers/work_areas/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:work_area) { Models::WorkArea.new(slug: 'the-slug') }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(context, work_area: work_area, repository: repository) }

        its(:default_repository) { should respond_to :scope_proxied_objects_for_the_user_and_proxy_for_type }

        it 'exposes submission_windows that are available to the user' do
          expect(repository).to receive(:scope_proxied_objects_for_the_user_and_proxy_for_type).
            with(user: current_user, proxy_for_type: Models::SubmissionWindow, where: { work_area: work_area })
          subject.submission_windows
        end

        it 'exposes submission_windows?' do
          expect(subject).to receive(:submission_windows).and_return([1])
          expect(subject.submission_windows?).to be_truthy
        end

        it 'exposes processing_state' do
          allow(work_area).to receive(:processing_state).and_return('Hello')
          expect(subject.processing_state).to eq('Hello')
        end

        it 'sets the work_area (which is private)' do
          expect(subject.send(:work_area)).to eq(work_area)
        end

        it 'will compose actions for the submission window' do
          expect(ComposableElements::ProcessingActionsComposer).to receive(:new).
            with(user: current_user, entity: work_area, repository: repository)
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
