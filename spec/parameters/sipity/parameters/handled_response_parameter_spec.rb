require 'spec_helper'
module Sipity
  module Parameters
    RSpec.describe HandledResponseParameter do
      let(:status) { :success }
      let(:work_area) { double(slug: 'hello') }
      let(:object) { double('Object', to_work_area: work_area) }
      let(:template) { 'named/template' }

      subject { described_class.new(status: status, object: object, template: template) }
      its(:status) { should eq status }
      its(:object) { should eq object }
      its(:template) { should eq template }

      it 'will fail to initialize if the status is not a symbol' do
        expect { described_class.new(status: double, object: object, template: template) }.
          to raise_error(Exceptions::InvalidHandledResponseStatus)
      end

      it 'will yield each additional view path slug' do
        expect { |b| subject.with_each_additional_view_path_slug(&b) }.to yield_successive_args('', work_area.slug)
      end
    end
  end
end
