require 'spec_helper'
require 'sipity/response_handlers/submission_window_handler'

module Sipity
  module ResponseHandlers
    module SubmissionWindowHandler
      RSpec.describe SuccessResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }

        it 'will coordinate the rendering of the template' do
          described_class.call(handler: handler)
          expect(handler).to have_received(:render).with(template: handler.template)
        end
      end

      RSpec.describe SubmitSuccessResponder do
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'a_slug', work_area: work_area) }
        let(:work_area) { Models::WorkArea.new(slug: 'area_slug') }
        let(:handler) { double(redirect_to: true, submission_window_path: true, work_submission_path: true) }
        let(:work) { Models::Work.new(id: 'an_id') }
        let(:path) { '/redirected_to/this/path' }

        context 'for a SubmissionWindow' do
          it "will #respond by redirecting to the submission window's path" do
            allow(handler).to receive(:response_object).and_return(submission_window)
            expect(handler).to receive(:submission_window_path).
              with(work_area_slug: work_area.slug, submission_window_slug: submission_window.slug).
              and_return(path)
            expect(handler).to receive(:redirect_to).with(path)
            described_class.call(handler: handler)
          end
        end

        context 'for a Work' do
          it "will #respond by redirecting to the work's path" do
            allow(handler).to receive(:response_object).and_return(work)
            expect(handler).to receive(:work_submission_path).with(work_id: work.id).and_return(path)
            expect(handler).to receive(:redirect_to).with(path)
            described_class.call(handler: handler)
          end
        end

        context 'for something that can be converted to a submission window' do
          let(:viewable_object) { double(to_submission_window: submission_window) }
          it "will attempt to convert the object" do
            allow(handler).to receive(:response_object).and_return(viewable_object)
            expect(handler).to receive(:submission_window_path).
              with(work_area_slug: work_area.slug, submission_window_slug: submission_window.slug).
              and_return(path)
            expect(handler).to receive(:redirect_to).with(path)
            described_class.call(handler: handler)
          end
        end

        context 'for something else' do
          let(:viewable_object) { double }
          it "will attempt to convert the object but fail" do
            allow(handler).to receive(:response_object).and_return(viewable_object)
            expect(PowerConverter).to receive(:convert).with(viewable_object, to: :submission_window).and_call_original
            expect { described_class.call(handler: handler) }.to raise_error(PowerConverter::ConversionError)
          end
        end
      end

      RSpec.describe SubmitFailureResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }
        it 'will coordinate the rendering of the template' do
          described_class.call(handler: handler)
          expect(handler).to have_received(:render).with(template: handler.template, status: :unprocessable_entity)
        end
      end
    end
  end
end
