require 'spec_helper'

module Sipity
  module Models
    module Agent
      RSpec.describe FromIdentifierId do
        subject { described_class.new(identifier_id: 'bmV0aWQJc2hpbGwy', attributes: { height: 'tall', email: 'hworld@gmail.com' }) }
        its(:name) { should eq(subject.identifying_value) }
        its(:email) { should eq('hworld@gmail.com') }
        its(:ids) { should eq([subject.identifier_id]) }
        its(:strategy) { should eq('netid') }
        its(:identifying_value) { should eq('shill2') }
        its(:user_signed_in?) { should eq(false) }
        its(:height) { should eq('tall') }
        its(:agreed_to_application_terms_of_service?) { should eq(false) }

        it 'will adhear to the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
      end
    end
  end
end
