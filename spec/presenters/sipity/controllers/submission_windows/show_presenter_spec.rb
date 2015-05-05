require 'spec_helper'

module Sipity
  module Controllers
    module SubmissionWindows
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:submission_window) { double(slug: 'the-slug', work_area: work_area, work_area_slug: work_area.slug) }
        let(:work_area) { double(slug: 'work-area') }
        subject { described_class.new(context, submission_window: submission_window) }
        it { should be_a SubmissionWindowPresenter }

        context '#render_submission_window' do
          context 'for an ETD' do
            let(:controller) { double('Controller') }
            let(:context) { PresenterHelper::Context.new(current_user: current_user, controller: controller) }
            let(:work_area) { double(slug: 'etd') }
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
