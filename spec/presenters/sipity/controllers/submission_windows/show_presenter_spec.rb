require 'spec_helper'

module Sipity
  module Controllers
    module SubmissionWindows
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user, action_name: 'show', render: true) }
        let(:current_user) { double('Current User') }
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'the-slug', work_area: work_area) }
        let(:work_area) { Models::WorkArea.new(slug: 'work-area', partial_suffix: 'work_area') }
        subject { described_class.new(context, submission_window: submission_window) }
        it { should be_a SubmissionWindowPresenter }

        context '#render_submission_window' do
          context 'for a ULRA' do
            it 'will render the partial for ulra' do
              expect(context).to receive(:render).
                with(partial: "#{context.action_name}_#{submission_window.work_area_partial_suffix}", object: subject)
              subject.render_submission_window
            end
          end
          context 'for an ETD' do
            let(:controller) { double('Controller') }
            let(:context) { PresenterHelper::Context.new(current_user: current_user, controller: controller) }
            let(:work_area) { Models::WorkArea.new(slug: 'etd', partial_suffix: 'etd') }
            let(:etd_form) { double }
            let(:decorated_form) { double }

            it 'will render the current behavior of the ETD submissions' do
              expect(Runners::WorkRunners::New).to receive(:run).
                with(controller, attributes: {}).and_return([:status, etd_form])
              expect(Decorators::WorkDecorator).to receive(:decorate).
                with(etd_form).
                and_return(decorated_form)
              expect(subject).to receive(:render).
                with(template: 'sipity/controllers/works/new', locals: { model: decorated_form }).
                and_return(decorated_form)
              subject.render_submission_window
            end
          end
        end
      end
    end
  end
end
