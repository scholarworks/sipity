require "rails_helper"
require 'sipity/controllers/submission_window_presenter'
require 'sipity/controllers/submission_window_presenter'

module Sipity
  module Controllers
    RSpec.describe SubmissionWindowPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(submission_window: submission_window, current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:submission_window) { Models::SubmissionWindow.new(slug: 'the-slug', work_area: work_area) }
      let(:work_area) { Models::WorkArea.new(slug: 'work-area') }
      let(:repository) { QueryRepositoryInterface.new }
      subject { described_class.new(context, submission_window: submission_window, repository: repository) }

      its(:path) { is_expected.to eq("/areas/#{submission_window.work_area_slug}/#{submission_window.slug}") }
      its(:path_to_start_a_submission) do
        is_expected.to eq("/areas/#{submission_window.work_area_slug}/#{submission_window.slug}/do/start_a_submission")
      end
      its(:link) { is_expected.to eq(%(<a href="#{subject.path}">the-slug</a>)) }
      its(:slug) { is_expected.to eq(submission_window.slug) }

      it 'will compose actions for the submission window' do
        expect(ComposableElements::ProcessingActionsComposer).to receive(:new).with(user: current_user, entity: submission_window)
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
