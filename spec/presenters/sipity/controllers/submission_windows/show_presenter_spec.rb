require 'spec_helper'
require 'sipity/controllers/submission_windows/show_presenter'

module Sipity
  module Controllers
    module SubmissionWindows
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
        let(:current_user) { double('Current User') }
        let(:submission_window) do
          double(slug: 'the-slug', work_area_slug: 'another', work_area_partial_suffix: 'work_area', processing_action_name: 'hello')
        end
        subject { described_class.new(context, submission_window: submission_window) }
        it { should be_a SubmissionWindowPresenter }

        context '#render_submission_window' do
          context 'for a ULRA' do
            it 'will render the partial for ulra' do
              expect(context).to receive(:render).
                with(partial: "#{submission_window.processing_action_name}_#{submission_window.work_area_partial_suffix}", object: subject)
              subject.render_submission_window
            end
          end
          context 'for an ETD' do
            let(:controller) { double('Controller') }
            let(:context) { PresenterHelper::Context.new(current_user: current_user, controller: controller) }
            let(:submission_window) do
              double(slug: 'the-slug', work_area_slug: 'etd', work_area_partial_suffix: 'etd', processing_action_name: 'hello')
            end
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
