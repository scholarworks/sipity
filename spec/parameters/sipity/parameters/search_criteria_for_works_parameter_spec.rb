require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe SearchCriteriaForWorksParameter do

      context 'configuration' do
        subject { described_class }
        its(:default_order_by) { should be_a(String) }
        its(:order_by_options_for_select) { should be_a(Array) }
      end

      context 'instance' do
        subject { described_class.new }
        it { should respond_to(:user) }
        it { should respond_to(:processing_state) }
        it { should respond_to(:order_by) }
        it { should respond_to(:repository) }
        it { should respond_to(:proxy_for_type) }
      end
    end
  end
end
