require 'spec_helper'

module Sipity
  RSpec.describe ResponseHandlers do
    before do
      module MockContainer
        module SuccessResponse
          def self.respond(**_keywords)
          end
        end
      end
    end
    after { Sipity.send(:remove_const, :MockContainer) }
    let(:context) { double }
    let(:handled_response) { double(status: :success) }
    let(:template) { double }

    context '.handle_response' do
      it 'will build a handler then respond with that handler' do
        expect(MockContainer::SuccessResponse).to receive(:respond).
          with(context: context, handled_response: handled_response, template: template)
        described_class.handle_response(container: MockContainer, context: context, handled_response: handled_response, template: template)
      end
    end

    context '.build_response_handler' do
      it 'will return a response handler object' do
        actual = described_class.build_response_handler(container: MockContainer, handled_response_status: :success)
        expect(actual).to eq(MockContainer::SuccessResponse)
      end
    end
  end

  module ResponseHandlers
    RSpec.describe DefaultHandler do
      let(:context) { double(render: 'rendered', :view_object= => true, redirect_to: 'redirected_to') }
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
  end
end
