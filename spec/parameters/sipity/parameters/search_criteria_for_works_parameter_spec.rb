require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe SearchCriteriaForWorksParameter do

      context 'configuration' do
        subject { described_class }
        its(:default_order) { should be_a(String) }
        its(:order_options_for_select) { should be_a(Array) }
      end

      context 'instance' do
        subject { described_class.new }
        it { should respond_to(:user) }
        it { should respond_to(:processing_state) }
        it { should respond_to(:order) }
        it { should respond_to(:proxy_for_type) }
      end

      it 'will fallback on default order if an invalid order is given' do
        subject = described_class.new(order: 'chicken-sandwich')
        expect(subject.order).to eq(subject.send(:default_order))
      end
    end
  end
end
