require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe HandledResponseParameter do
      let(:status) { :success }
      let(:work_area) { double(slug: 'hello')}
      let(:object) { double('Object', to_work_area: work_area) }
      let(:template) { '/sipity/controllers/a/named/template' }

      subject { described_class.new(status: status, object: object, template: template) }
      its(:status) { should eq status }
      its(:object) { should eq object }
      its(:template) { should eq '/sipity/controllers/hello/a/named/template' }

      it 'will fail to initialize if the status is not a symbol' do
        expect { described_class.new(status: double, object: object, template: template) }.
          to raise_error(Exceptions::InvalidHandledResponseStatus)
      end
    end
  end
end
