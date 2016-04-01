require 'spec_helper'
require 'sipity/parameters/handled_response_parameter'
module Sipity
  module Parameters
    RSpec.describe HandledResponseParameter do
      let(:status) { :success }
      let(:work_area) { double(slug: 'hello') }
      let(:object) { double('Object', to_work_area: work_area, errors: []) }
      let(:template) { 'named/template' }

      subject { described_class.new(status: status, object: object, template: template) }
      its(:status) { is_expected.to eq status }
      its(:object) { is_expected.to eq object }
      its(:template) { is_expected.to eq template }

      it { is_expected.to delegate_method(:errors).to(:object) }

      it 'will raise to initialize if the status is not a symbol' do
        expect { described_class.new(status: double, object: object, template: template) }.
          to raise_error(Exceptions::InvalidHandledResponseStatus)
      end

      it 'will yield each additional view path slug' do
        expect { |b| subject.with_each_additional_view_path_slug(&b) }.to yield_successive_args('', 'core', work_area.slug)
      end

      it 'will use the object\'s template if one is assigned' do
        object = double('Object', to_work_area: work_area, template: 'kittens', errors: [])
        subject = described_class.new(status: status, object: object, template: template)
        expect(subject.template).to eq(object.template)
      end

      it 'will raise an exception if the object does not implement errors' do
        object = double('Object', to_work_area: work_area)
        expect { described_class.new(status: status, object: object, template: template) }.
          to raise_error(Sipity::Exceptions::InterfaceExpectationError)
      end
    end
  end
end
