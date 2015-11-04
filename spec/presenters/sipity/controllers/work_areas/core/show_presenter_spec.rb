require 'spec_helper'
require 'sipity/controllers/work_areas/core/show_presenter'
require 'sipity/controllers/work_areas/core/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        RSpec.describe ShowPresenter do
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

        RSpec.describe ShowPresenter::FilterFormPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new }
          let(:work_area) do
            double(
              input_name_for_select_processing_state: 'hello[world]',
              processing_state: 'new',
              processing_states_for_select: ['new', 'say'],
              input_name_for_select_sort_order: 'name[sort_order]',
              order_options_for_select: ['title', 'created_at'],
              order: 'title'
            )
          end

          subject { described_class.new(context, work_area: work_area) }

          its(:submit_button) { should be_html_safe }
          its(:select_tag_for_processing_state) { should be_html_safe }

          it 'will expose select_tag_for_processing_state' do
            expect(subject.select_tag_for_processing_state).to have_tag('select[name="hello[world]"]') do
              with_tag("option[value='']", text: '')
              with_tag("option[value='new'][selected='selected']", text: 'New')
              with_tag("option[value='say']", text: 'Say')
            end
          end

          it 'will expose select_tag_for_sort_order' do
            expect(subject.select_tag_for_sort_order).to have_tag('select[name="name[sort_order]"]') do
              with_tag("option[value='']", text: '')
              with_tag("option[value='title'][selected='selected']", text: 'Title')
              with_tag("option[value='created_at']", text: 'Created at')
            end
          end

          it 'will have a submit button' do
            expect(subject.submit_button).to have_tag('input.btn.btn-default[type="submit"]')
          end
        end

        RSpec.describe ShowPresenter::WorkPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(repository: QueryRepositoryInterface.new) }
          let(:work) do
            double('Work', title: 'hello', work_type: 'doctoral_dissertation', processing_state: 'new', created_at: Time.zone.today)
          end

          subject { described_class.new(context, work: work) }

          its(:title) { should be_html_safe }
          its(:processing_state) { should eq('New') }
          its(:date_created) { should be_a(String) }
          its(:creator_names_to_sentence) { should be_a(String) }
          its(:work_type) { should eq('Doctoral dissertation') }

          it 'will delegate path to PowerConverter' do
            expect(PowerConverter).to receive(:convert).with(work, to: :access_path).and_return('/the/path')
            expect(subject.path).to eq('/the/path')
          end
        end
      end
    end
  end
end
