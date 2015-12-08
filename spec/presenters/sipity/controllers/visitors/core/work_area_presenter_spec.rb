require 'spec_helper'
require 'sipity/controllers/work_areas/core/show_presenter'

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

          its(:default_translator) { should respond_to :call }
          its(:default_repository) { should respond_to :find_submission_window_by }

          let(:submission_window) { double }
          let(:processing_action) { double(name: 'start_a_submission') }
          before do
            allow(repository).to receive(:find_submission_window_by).and_return(submission_window)
            allow_any_instance_of(described_class).to receive(:convert_to_processing_action).and_return(processing_action)
          end

          context '#search_criteria' do
            subject do
              described_class.new(context, work_area: work_area, repository: repository, translator: translator).send(:search_criteria)
            end
            its(:work_area) { should eq(work_area) }
          end

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

          it 'will render a filter form' do
            expect(context).to receive(:form_tag).and_yield
            expect { |b| subject.filter_form(&b) }.to yield_control
          end

          it 'exposes works as an enumerable' do
            expect(repository).to receive(:find_works_via_search).with(criteria: kind_of(Parameters::SearchCriteriaForWorksParameter)).
              and_call_original
            subject.works
          end

          it 'will paginate the works' do
            works = double
            allow(repository).to receive(:find_works_via_search).and_return(works)
            expect(context).to receive(:paginate).with(works)
            subject.paginate_works
          end
        end
      end
    end
  end
end
