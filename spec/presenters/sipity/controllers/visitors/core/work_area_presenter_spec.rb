require 'spec_helper'
require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Core
        RSpec.describe WorkAreaPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) { double(slug: 'the-slug', title: 'The Slug', processing_state: 'new', order: 'title', page: 1) }
          let(:repository) { QueryRepositoryInterface.new }
          let(:translator) { double(call: true) }
          subject { described_class.new(context, work_area: work_area, repository: repository, translator: translator) }

          its(:default_translator) { is_expected.to respond_to :call }
          its(:default_repository) { is_expected.to respond_to :find_submission_window_by }

          let(:submission_window) { double }
          let(:processing_action) { double(name: 'start_a_submission') }
          before do
            allow(repository).to receive(:find_submission_window_by).and_return(submission_window)
            allow_any_instance_of(described_class).to receive(:convert_to_processing_action).and_return(processing_action)
          end

          context '#translate' do
            it 'will delegate to the translator' do
              identifier = double
              expect(translator).to receive(:call).
                with(scope: "processing_actions.show", subject: work_area, object: identifier, predicate: :label)
              subject.translate(identifier)
            end
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

          it { is_expected.to delegate_method(:name).to(:work_area) }
          it { is_expected.to delegate_method(:resourceful_actions).to(:processing_actions) }
          it { is_expected.to delegate_method(:resourceful_actions?).to(:processing_actions) }
          it { is_expected.to delegate_method(:state_advancing_actions).to(:processing_actions) }
          it { is_expected.to delegate_method(:state_advancing_actions).to(:processing_actions) }
          it { is_expected.to delegate_method(:enrichment_actions?).to(:processing_actions) }
          it { is_expected.to delegate_method(:enrichment_actions?).to(:processing_actions) }

          its(:to_work_area) { is_expected.to eq(subject.send(:work_area)) }

          it 'will initialize the presumptive submission window' do
            expect(repository).to receive(:find_submission_window_by).
              with(work_area: work_area, slug: described_class::SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED).and_return(submission_window)
            subject
          end

          it 'will initialize the presumptive processing action' do
            expect_any_instance_of(described_class).to receive(:convert_to_processing_action).
              with(described_class::ACTION_NAME_THAT_IS_HARD_CODED, scope: submission_window).and_return(processing_action)
            subject
          end

          it 'exposes #start_a_submission_path' do
            allow(PowerConverter).to receive(:convert).and_call_original
            expect(PowerConverter).to receive(:convert).with(submission_window, to: :processing_action_root_path).and_return('/hello/dolly')
            expect(subject.start_a_submission_path).to eq("/hello/dolly/#{processing_action.name}")
          end
        end
      end
    end
  end
end
