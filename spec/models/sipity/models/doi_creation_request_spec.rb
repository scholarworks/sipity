require 'rails_helper'

module Sipity
  module Models
    RSpec.describe DoiCreationRequest, type: :model do
      subject { described_class.new }
      it 'will initialize with a default state' do
        expect(subject.state).to be_present
      end
    end
  end
end
