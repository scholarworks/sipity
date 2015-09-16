require 'spec_helper'
require 'sipity/response_handlers/work_submission_handler'
require 'sipity/response_handlers/work_submission_handler'

module Sipity
  module ResponseHandlers
    module WorkSubmissionHandler
      RSpec.describe SuccessResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }

        it 'will coordinate the rendering of the template' do
          described_class.call(handler: handler)
          expect(handler).to have_received(:render).with(template: handler.template)
        end
      end

      RSpec.describe SubmitSuccessResponder do
        let(:handler) { double(redirect_to: true, response_object: double(id: '123')) }

        it 'will coordinate the rendering of the template' do
          expect(PowerConverter).to receive(:convert_to_access_path).and_return('/hello/world')
          described_class.call(handler: handler)
          expect(handler).to have_received(:redirect_to).with('/hello/world')
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
