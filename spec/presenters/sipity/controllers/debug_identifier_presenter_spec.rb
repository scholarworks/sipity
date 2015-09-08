require 'spec_helper'
require 'cogitate/client'

module Sipity
  module Controllers
    RSpec.describe DebugIdentifierPresenter, type: :presenter do
      let(:strategy) { 'netid' }
      let(:identifying_value) { 'hworld' }
      let(:identifier_id) { Cogitate::Client.encoded_identifier_for(strategy: strategy, identifying_value: identifying_value) }
      let(:identifier) { double(identifier_id: identifier_id, permission_grant_level: 'hello') }
      let(:context) { PresenterHelper::Context.new }
      subject do
        described_class.new(context, debug_identifier: identifier)
      end

      it { should delegate_method(:permission_grant_level).to(:debug_identifier) }
      it { should delegate_method(:identifier_id).to(:debug_identifier) }
      its(:strategy) { should eq(strategy) }
      its(:identifying_value) { should eq(identifying_value) }

      it 'will guard the interface of the identifier' do
        expect { described_class.new(context, debug_identifier: double) }.to raise_error(Exceptions::InterfaceExpectationError)
      end
    end
  end
end
