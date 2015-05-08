require 'spec_helper'

module Sipity
  RSpec.describe ResponseHandlers do
    before do
      module MockContainer
        module SuccessResponder
          def self.call(handler:)
            # I want to make sure the interface is correct, but Rubocop wants
            # me to do something with the keyword.
            _handler = handler
          end
        end
      end
    end
    after { Sipity.send(:remove_const, :MockContainer) }
    let(:context) { double(render: true, redirect_to: true, :view_object= => true) }
    let(:handled_response) { double(status: :success, object: double, template: double) }

    context '.handle_response' do
      it 'will build a handler then respond with that handler' do
        expect(MockContainer::SuccessResponder).to receive(:call).with(handler: kind_of(described_class::DefaultHandler))
        described_class.handle_response(
          container: MockContainer, context: context, handled_response: handled_response
        )
      end
    end

    context '.build_responder' do
      it 'will return a handler object' do
        actual = described_class.build_responder(container: MockContainer, handled_response_status: :success)
        expect(actual).to eq(MockContainer::SuccessResponder)
      end
    end
  end

  module ResponseHandlers
    RSpec.describe DefaultHandler do
      let(:context) { double(render: 'rendered', :view_object= => true, redirect_to: 'redirected_to') }
      let(:viewable_object) { double }
      let(:handled_response) { double(object: viewable_object, template: 'show') }
      subject { described_class.new(context: context, handled_response: handled_response) }
      it 'will #respond by rendering the context' do
        expect(subject.respond).to eq(context.render)
      end

      it 'will .respond by rendering the context' do
        expect(described_class.respond(context: context, handled_response: handled_response)).to eq(context.render)
        expect(context).to have_received(:render).with(template: 'show')
      end

      it 'accepts a custom responder' do
        responder = double(call: true)
        subject = described_class.new(context: context, handled_response: handled_response, responder: responder)
        subject.respond
        expect(responder).to have_received(:call).with(handler: subject)
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
          expect { described_class.new(context: context, handled_response: double(template: 'show')) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
        it '#handled_response must implement #template' do
          expect { described_class.new(context: context, handled_response: double(object: double)) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
      end
    end
  end
end
