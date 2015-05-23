require 'spec_helper'
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
        let(:handler) { double(redirect_to: true, response_object: double(id: '123'), work_submission_path: true) }

        it 'will coordinate the rendering of the template' do
          expect(handler).to receive(:work_submission_path).with(work_id: handler.response_object.id).and_return(:path)
          described_class.call(handler: handler)
          expect(handler).to have_received(:redirect_to).with(:path)
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
