require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe EntityWithAdditionalAttributesParameter do
      let(:additional_attributes) do
        [
          double(key: 'abstract', value: 'world'),
          Models::AdditionalAttribute.new(key: 'abstract', value: 'something'),
          Models::AdditionalAttribute.new(key: 'majors', value: 'hello')
        ]
      end
      let(:entity) { double }
      subject { described_class.new(additional_attributes: additional_attributes, entity: entity) }
      its(:entity) { should eq entity }
      its(:any?) { should be_truthy }
      its(:count) { should eq(2) }
    end
  end
end
