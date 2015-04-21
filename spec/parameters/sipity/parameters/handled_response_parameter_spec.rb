require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe HandledResponseParameter do
      let(:status) { :success }
      let(:object) { double('Object') }

      subject { described_class.new(status: status, object: object) }
      its(:status) { should eq status }
      its(:object) { should eq object }

      it 'will fail to initialize if the status is not a symbol' do
        expect { described_class.new(status: double, object: object) }.to raise_error(Exceptions::InvalidHandledResponseStatus)
      end
    end
  end
end
