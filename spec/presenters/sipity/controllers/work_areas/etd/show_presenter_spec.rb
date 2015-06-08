require 'spec_helper'
require 'sipity/controllers/work_areas/etd/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Etd
        RSpec.describe ShowPresenter do
          let(:context) { PresenterHelper::Context.new(current_user: current_user) }
          let(:current_user) { double('Current User') }
          let(:work_area) { Models::WorkArea.new(slug: 'the-slug') }
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

          its(:view_submitted_etds_url) { should match(%r{\Ahttps://curate.nd.edu})}
        end
      end
    end
  end
end
