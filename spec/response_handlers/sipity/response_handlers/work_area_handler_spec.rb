require 'spec_helper'
require 'sipity/response_handlers/work_area_handler'

module Sipity
  module ResponseHandlers
    module WorkAreaHandler
      RSpec.describe SuccessResponse do
        let(:context) { double(render: 'rendered', :view_object= => true) }
        let(:viewable_object) { double }
        let(:handled_response) { double(object: viewable_object) }
        subject { described_class.new(context: context, handled_response: handled_response) }
        it 'will #respond by rendering the context' do
          expect(subject.respond).to eq(context.render)
        end

        it 'will .respond by rendering the context' do
          expect(described_class.respond(context: context, handled_response: handled_response)).to eq(context.render)
        end

        context 'collaborating objects expected interface' do
          it '#context must implement #view_object=' do
            expect { described_class.new(context: double(render: true), handled_response: handled_response) }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#context must implement #render' do
            expect { described_class.new(context: double(:view_object= => true), handled_response: handled_response) }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
          it '#handled_response must implement #object' do
            expect { described_class.new(context: context, handled_response: double) }.
              to raise_error(Exceptions::InterfaceExpectationError)
          end
        end
      end
    end
  end
end
