require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe HandledResponseParameter do
      let(:status) { :success }
      let(:object) { double('Object') }
      let(:template) { 'a/template' }

      subject { described_class.new(status: status, object: object, template: template) }
      its(:status) { should eq status }
      its(:object) { should eq object }
      its(:template) { should eq template }

      it 'will fail to initialize if the status is not a symbol' do
        expect { described_class.new(status: double, object: object, template: template) }.
          to raise_error(Exceptions::InvalidHandledResponseStatus)
      end
    end
  end
end
