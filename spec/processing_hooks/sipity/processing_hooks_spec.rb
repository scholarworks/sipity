require 'spec_helper'

module Sipity
  # A container module for functions that are called as part of
  # a Processing action being taken.
  RSpec.describe ProcessingHooks do
    let(:call_parameter_interface) { [[:keyreq, :action], [:keyreq, :entity], [:keyreq, :requested_by], [:keyrest, :keywords]] }

    context '.call' do
      it 'will implement a specific parameter interface' do
        expect(described_class.method(:call).parameters).to eq(call_parameter_interface)
      end
    end
  end
end
