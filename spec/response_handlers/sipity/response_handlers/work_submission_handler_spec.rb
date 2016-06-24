require "rails_helper"
require 'sipity/response_handlers/work_submission_handler'
require 'sipity/response_handlers/work_submission_handler'

module Sipity
  module ResponseHandlers
    module WorkSubmissionHandler
      RSpec.describe SuccessResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }
        context '.for_controller' do
          it 'will coordinate the rendering of the template' do
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:render).with(template: handler.template)
          end
        end

        context '.for_command_line' do
          it 'will return true' do
            expect(described_class.for_command_line(handler: handler)).to eq(true)
          end
        end
      end

      RSpec.describe RedirectResponder do
        context '.for_controller' do
          let(:handler) { double('Handler', response_object: double(url: 'google.com'), redirect_to: true) }
          it 'will coordinate the rendering of the template' do
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:redirect_to).with(handler.response_object.url)
          end
        end

        context '.for_command_line' do
          let(:handler) { double('Handler', response_object: double, response_errors: [], response_status: :redirect) }
          it 'will raise an exception' do
            expect do
              described_class.for_command_line(handler: handler)
            end.to raise_error(Sipity::Exceptions::ResponseHandlerError)
          end
        end
      end

      RSpec.describe SubmitSuccessResponder do
        let(:handler) { double(redirect_to: true, response_object: double(id: '123')) }
        context '.for_controller' do
          it 'will coordinate the rendering of the template' do
            expect(PowerConverter).to receive(:convert_to_access_path).and_return('/hello/world')
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:redirect_to).with('/hello/world')
          end
        end

        context '.for_command_line' do
          it 'will return true' do
            expect(described_class.for_command_line(handler: handler)).to eq(true)
          end
        end
      end

      RSpec.describe SubmitFailureResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }
        context '.for_controller' do
          it 'will coordinate the rendering of the template' do
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:render).with(template: handler.template, status: :unprocessable_entity)
          end
        end
        context '.for_command_line' do
          let(:handler) { double(response_object: double, response_errors: [], response_status: :failure) }
          it 'will raise an exception' do
            expect do
              described_class.for_command_line(handler: handler)
            end.to raise_error(Sipity::Exceptions::ResponseHandlerError)
          end
        end
      end
    end
  end
end
