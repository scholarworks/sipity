require 'spec_helper'

module Sip
  RSpec.describe RequestADoiForm do
    let(:header) { double }
    subject { described_class.new(header: header) }

    it 'has a default decorator that implements #decorate' do
      # I want the #decorator method to remain private
      # This example was to test a default path.
      expect(subject.send(:decorator)).to respond_to(:decorate)
    end
  end
end
