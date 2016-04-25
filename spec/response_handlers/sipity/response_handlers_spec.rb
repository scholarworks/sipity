require 'spec_helper'
require 'sipity/response_handlers'

module Sipity
  RSpec.describe ResponseHandlers do
    before do
      module MockContainer
        module SuccessResponder
          def self.for_controller(handler:)
            # I want to make sure the interface is correct, but Rubocop wants
            # me to do something with the keyword.
            _handler = handler
          end

          def self.for_command_line(*args)
            return *args
          end
        end
      end
    end
    after { Sipity.send(:remove_const, :MockContainer) }
    let(:context) { double(render: true, redirect_to: true, :view_object= => true, prepend_processing_action_view_path_with: true) }
    let(:handled_response) do
      double(status: :success, errors: [], object: double, template: double, with_each_additional_view_path_slug: true)
    end

    context '.handle_controller_response' do
      it 'will build a handler then respond with that handler' do
        expect(MockContainer::SuccessResponder).to(
          receive(:for_controller).with(handler: kind_of(described_class::ControllerResponseHandler))
        )
        described_class.handle_controller_response(
          container: MockContainer, context: context, handled_response: handled_response
        )
      end
    end

    context '.handle_command_line_response' do
      it 'will build a handler then respond with that handler' do
        expect(MockContainer::SuccessResponder).to receive(:for_command_line).with(
          handler: kind_of(described_class::CommandLineResponseHandler)
        )
        described_class.handle_command_line_response(
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
    RSpec.describe CommandLineResponseHandler do
      let(:responder) { double(for_command_line: true) }
      let(:handled_response) { double(status: :success, errors: [], object: double) }
      subject { described_class.new(handled_response: handled_response, responder: responder) }

      it 'exposes .respond as a convenience method' do
        expect_any_instance_of(described_class).to receive(:respond)
        described_class.respond(handled_response: handled_response, responder: responder)
      end

      it 'will #respond by calling the responder#for_command_line' do
        expect(responder).to receive(:for_command_line).with(handler: subject).and_return(:for_command_line_called)
        expect(subject.respond).to eq(:for_command_line_called)
      end
      it { is_expected.to delegate_method(:status).to(:handled_response).with_prefix(:response) }
      it { is_expected.to delegate_method(:object).to(:handled_response).with_prefix(:response) }
      it { is_expected.to delegate_method(:errors).to(:handled_response).with_prefix(:response) }
    end

    RSpec.describe ControllerResponseHandler do
      let(:responder) { double(for_controller: true) }
      let(:context) { double(render: true, redirect_to: true, :view_object= => true, prepend_processing_action_view_path_with: true) }
      let(:handled_response) do
        double(status: :success, errors: [], object: double, template: 'show', with_each_additional_view_path_slug: true)
      end
      subject { described_class.new(context: context, handled_response: handled_response, responder: responder) }
      it 'will #respond by rendering the context' do
        expect(subject.respond).to eq(context.render)
      end

      it { is_expected.to delegate_method(:status).to(:handled_response).with_prefix(:response) }
      it { is_expected.to delegate_method(:object).to(:handled_response).with_prefix(:response) }
      it { is_expected.to delegate_method(:errors).to(:handled_response).with_prefix(:response) }

      it 'will coordinate updating view path information with the context' do
        expect(handled_response).to receive(:with_each_additional_view_path_slug).and_yield('core').and_yield('ulra')
        expect(context).to receive(:prepend_processing_action_view_path_with).with(slug: 'core').ordered
        expect(context).to receive(:prepend_processing_action_view_path_with).with(slug: 'ulra').ordered
        described_class.new(context: context, handled_response: handled_response, responder: responder)
      end

      it 'will .respond by calling the responder with the handler' do
        expect(described_class.respond(context: context, handled_response: handled_response, responder: responder)).to eq(context.render)
        expect(responder).to have_received(:for_controller).with(handler: kind_of(described_class))
      end

      it 'accepts a custom responder' do
        subject = described_class.new(context: context, handled_response: handled_response, responder: responder)
        subject.respond
        expect(responder).to have_received(:for_controller).with(handler: subject)
      end

      context '#method_missing' do
        it 'will delegate all *_path methods to the context' do
          expect(context).to receive(:submission_window_path).with(key: 'value')
          subject.submission_window_path(key: 'value')
        end
        it 'will pass through if the method_name is not *_path' do
          expect { subject.obviously_missing }.to raise_error(NoMethodError)
        end
      end

      context '#respond_to?' do
        it 'will respond to all *_path methods (if the context does)' do
          context = double(
            render: 'rendered',
            prepend_processing_action_view_path_with: true,
            :view_object= => true,
            redirect_to: 'redirected_to',
            submission_window_path: true
          )
          subject = described_class.new(context: context, handled_response: handled_response, responder: responder)
          expect(subject.respond_to?(:submission_window_path)).to eq(true)
        end
        it 'will pass through if the method_name is not *_path' do
          expect(subject.respond_to?(:obviously_missing)).to be_falsey
        end
      end

      context 'collaborating objects expected interface' do
        it '#context must implement #view_object=' do
          expect { described_class.new(context: double(render: true), handled_response: handled_response, responder: responder) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
        it '#context must implement #render' do
          expect { described_class.new(context: double(:view_object= => true), handled_response: handled_response, responder: responder) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
        it '#handled_response must implement #object' do
          expect { described_class.new(context: context, handled_response: double(template: 'show'), responder: responder) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
        it '#handled_response must implement #template' do
          expect { described_class.new(context: context, handled_response: double(object: double), responder: responder) }.
            to raise_error(Exceptions::InterfaceExpectationError)
        end
      end
    end
  end
end
