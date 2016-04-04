require 'spec_helper'
require 'sipity/decorators/base_object_with_composed_attributes_delegator'
module Sipity
  module Decorators
    RSpec.describe BaseObjectWithComposedAttributesDelegator do
      let(:base_object) { double(chicken: 'hen', age: '1') }
      let(:keywords) { { title: 'wonder', chicken: 'rubber' } }

      subject { described_class.new(base_object, keywords) }

      it 'will expose the existing methods of the object' do
        expect(subject.chicken).to eq(base_object.chicken)
      end

      it { is_expected.to respond_to :age }
      it { is_expected.to respond_to :chicken }
      it { is_expected.to respond_to :title }

      it 'will expose additional collaborators of the object' do
        expect(subject.title).to eq(keywords.fetch(:title))
      end

      it 'will be like its base_class' do
        expect(subject.is_a?(base_object.class)).to eq(true)
      end
    end
  end
end
