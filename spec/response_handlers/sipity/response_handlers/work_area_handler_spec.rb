require 'spec_helper'
require 'sipity/response_handlers/work_area_handler'
require 'sipity/response_handlers/work_area_handler'

module Sipity
  module ResponseHandlers
    module WorkAreaHandler
      RSpec.describe SuccessResponder do
        let(:handler) { double(render: 'rendered', template: 'show') }

        it 'will coordinate the rendering of the template' do
          described_class.call(handler: handler)
          expect(handler).to have_received(:render).with(template: handler.template)
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
