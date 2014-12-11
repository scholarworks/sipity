require 'spec_helper'
require 'sipity/exceptions'

module Sipity
  module Exceptions
    RSpec.describe InvalidStateError do
      let(:entity) { '"Entity"' }
      let(:actual) { '"actual"' }
      context 'without an expected state' do
        let(:expected) { nil }
        subject { described_class.new(entity: entity, actual: actual, expected: expected) }
        its(:entity) { should eq(entity) }
        its(:actual) { should eq(actual) }
        its(:expected) { should eq(expected) }
        its(:message) { should be_a(String) }
      end

      context 'with an expected state' do
        let(:expected) { '"expected"' }
        subject { described_class.new(entity: entity, actual: actual, expected: expected) }
        its(:entity) { should eq(entity) }
        its(:actual) { should eq(actual) }
        its(:message) { should be_a(String) }
      end
    end
  end
end
