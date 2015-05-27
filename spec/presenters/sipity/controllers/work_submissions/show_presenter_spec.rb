require 'spec_helper'
require 'sipity/controllers/work_submissions/show_presenter'

module Sipity
  module Controllers
    module WorkSubmissions
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
        let(:current_user) { double('Current User') }
        let(:work_submission) { Models::Work.new(id: 'hello-world') }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(context, work_submission: work_submission) }

        its(:default_repository) { should respond_to :find_current_comments_for }

        it 'exposes processing_state' do
          allow(work_submission).to receive(:processing_state).and_return('Hello')
          expect(subject.processing_state).to eq('Hello')
        end

        it 'will expose #render_processing_state_notice' do
          expect(context).to receive(:render).with(partial: "/processing_state_notice", object: subject)
          subject.render_processing_state_notice
        end

        it 'will expose #collaborators?' do
          expect(work_submission).to receive(:collaborators).and_return([])
          expect(subject.collaborators?).to be_falsey
        end

        it { should delegate_method(:collaborators).to(:work_submission) }

        context '#render_current_comments' do
          subject { described_class.new(context, work_submission: work_submission, repository: repository) }
          it 'will return nil if there are no comments in the repository' do
            expect(repository).to receive(:find_current_comments_for).with(entity: work_submission).and_return([])
            expect(subject.render_current_comments).to be_nil
          end

          it 'will render the current_comments partial if there are comments in the repository' do
            expect(repository).to receive(:find_current_comments_for).with(entity: work_submission).and_return([double])
            expect(context).to receive(:render).with(partial: "/current_comments", object: kind_of(Parameters::EntityWithCommentsParameter))
            expect(subject.render_current_comments).to be_nil
          end
        end

        context '#render_enrichment_action_set' do
          it 'will render the partial if there are elements' do
            action_set = double(present?: true)
            expect_any_instance_of(ComposableElements::ProcessingActionsComposer).
              to receive(:action_set_for).with(name: 'enrichment_actions', identifier: 'required').and_return(action_set)
            expect(context).to receive(:render).with(partial: "/enrichment_action_set", object: action_set)
            subject.render_enrichment_action_set('required')
          end
          it 'will render the partial if there are elements' do
            action_set = double(present?: false)
            expect_any_instance_of(ComposableElements::ProcessingActionsComposer).
              to receive(:action_set_for).with(name: 'enrichment_actions', identifier: 'required').and_return(action_set)
            expect(context).to_not receive(:render)
            subject.render_enrichment_action_set('required')
          end
        end

        context '#render_state_advancing_action_set' do
          it 'will render the partial if there are elements' do
            action_set = double(present?: true)
            expect_any_instance_of(ComposableElements::ProcessingActionsComposer).
              to receive(:action_set_for).with(name: 'state_advancing_actions').and_return(action_set)
            expect(context).to receive(:render).with(partial: "/state_advancing_action_set", object: action_set)
            subject.render_state_advancing_action_set
          end
        end

        it 'will expose #section that accepts an identifier' do
          expect(TranslationAssistant).to receive(:call)
          subject.section('overview')
        end

        it 'will expose #work_type and delegate to the TranslationAssistant' do
          expect(TranslationAssistant).to receive(:call)
          subject.work_type
        end

        it 'will expose #work_publication_strategy and delegate to the TranslationAssistant' do
          expect(TranslationAssistant).to receive(:call)
          subject.work_publication_strategy
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
