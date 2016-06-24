require "rails_helper"
require 'sipity/parameters/entity_with_additional_attributes_parameter'

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
      its(:entity) { is_expected.to eq entity }
      its(:any?) { is_expected.to be_truthy }
      its(:count) { is_expected.to eq(2) }
    end
  end
end
