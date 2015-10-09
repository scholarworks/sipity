require 'spec_helper'
require 'sipity/constraints/allow_mock_authentication_constraint'

module Sipity
  module Constraints
    RSpec.describe AllowMockAuthenticationConstraint do
      context '.matches?' do
        [
          ['false', false],
          ['true', true],
          ['sure', true]
        ].each do |value, expected|
          it "will treat Figaro.env.cogitate_allow_mock_authentication of #{value.inspect} to be #{expected.inspect}" do
            expect(Figaro.env).to receive(:cogitate_allow_mock_authentication).and_return(value)
            request = double('Request')
            expect(described_class.matches?(request)).to eq(expected)
          end
        end
      end
    end
  end
end
