require 'rails_helper'

module Sipity
  module Models
    RSpec.describe AccountPlaceholder, type: :model do
      subject { described_class.new }
      it 'will initialize with a default state' do
        expect(subject.state).to be_present
      end

      it 'will raise an ArgumentError if you provide an invalid state' do
        expect { subject.state = '__incorrect_state__' }.to raise_error(ArgumentError)
      end
    end
  end
end
