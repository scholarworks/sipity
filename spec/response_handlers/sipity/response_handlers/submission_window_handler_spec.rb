require 'spec_helper'
require 'sipity/response_handlers/submission_window_handler'

module Sipity
  module ResponseHandlers
    module SubmissionWindowHandler
      RSpec.describe SuccessResponse do
        let(:context) { double(render: 'rendered', :view_object= => true) }
        let(:viewable_object) { double }
        let(:handled_response) { double(object: viewable_object) }
        subject { described_class.new(context: context, handled_response: handled_response, template: 'show') }
        it 'will #respond by rendering the context' do
          expect(subject.respond).to eq(context.render)
        end

        it 'will .respond by rendering the context' do
          expect(described_class.respond(context: context, handled_response: handled_response, template: 'show')).to eq(context.render)
          expect(context).to have_received(:render).with(template: 'show')
        end

        context 'collaborating objects expected interface' do
          it '#context must implement #view_object=' do
            expect { described_class.new(context: double(render: true), handled_response: handled_response, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#context must implement #render' do
            expect { described_class.new(context: double(:view_object= => true), handled_response: handled_response, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#handled_response must implement #object' do
            expect { described_class.new(context: context, handled_response: double, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
        end
      end

      RSpec.describe SubmitSuccessResponse do
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'a_slug', work_area: work_area) }
        let(:viewable_object) { submission_window }
        let(:work_area) { Models::WorkArea.new(slug: 'area_slug') }
        let(:context) { double(render: :rendered, redirect_to: :redirected_to, :view_object= => true) }
        let(:handled_response) { double(object: viewable_object) }
        subject { described_class.new(context: context, handled_response: handled_response, template: 'show') }

        it 'will .respond by delegating to an instance' do
          expect_any_instance_of(described_class).to receive(:respond)
          described_class.respond(context: context, handled_response: handled_response, template: 'show')
        end

        context 'for a SubmissionWindow' do
          it "will #respond by redirecting to the submission window's path" do
            path = '/path/to/submission_window'
            expect(context).to receive(:submission_window_path).
              with(work_area_slug: work_area.slug, submission_window_slug: submission_window.slug).
              and_return(path)
            expect(context).to receive(:redirect_to).with(path)
            subject.respond
          end
        end

        context 'for a Work' do
          let(:viewable_object) { Models::Work.new(id: 'an_id') }

          it "will #respond by redirecting to the submission window's path" do
            path = '/path/to/work'
            expect(context).to receive(:work_submission_path).with(work_id: viewable_object.id).and_return(path)
            expect(context).to receive(:redirect_to).with(path)
            subject.respond
          end
        end

        context 'for something that can be converted to a submission window' do
          let(:viewable_object) { double(to_submission_window: submission_window) }
          it "will attempt to convert the object" do
            path = '/path/to/submission_window'
            expect(context).to receive(:submission_window_path).
              with(work_area_slug: work_area.slug, submission_window_slug: submission_window.slug).
              and_return(path)
            expect(context).to receive(:redirect_to).with(path)
            subject.respond
          end
        end

        context 'for something else' do
          let(:viewable_object) { double }
          it "will attempt to convert the object" do
            expect(PowerConverter).to receive(:convert).with(viewable_object, to: :submission_window).and_call_original
            expect { subject.respond }.to raise_error(PowerConverter::ConversionError)
          end
        end

        context 'collaborating objects expected interface' do
          it '#context must implement #view_object=' do
            expect { described_class.new(context: double(render: true), handled_response: handled_response, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#context must implement #render' do
            expect { described_class.new(context: double(:view_object= => true), handled_response: handled_response, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#handled_response must implement #object' do
            expect { described_class.new(context: context, handled_response: double, template: 'show') }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
        end
      end
    end
  end
end
