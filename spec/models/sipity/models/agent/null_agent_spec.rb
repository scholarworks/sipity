require 'spec_helper'

module Sipity
  module Models
    class Agent
      RSpec.describe NullAgent do
        subject { described_class.new }
        its(:name) { should eq('anonymous') }
        its(:email) { should eq('') }
        its(:ids) { should eq([]) }
        its(:user_signed_in?) { should eq(false) }
        its(:agreed_to_application_terms_of_service?) { should eq(false) }

        it 'will adhear to the AgentInterface' do
          Contract.valid?(subject, Sipity::Interfaces::AgentInterface)
        end
      end
    end
  end
end
