require 'spec_helper'

module Sipity
  module Models
    module AuthenticationAgent
      RSpec.describe NullAgent do
        subject { described_class.new }
        its(:name) { should eq('anonymous') }
        its(:email) { should eq('') }
        its(:ids) { should eq([]) }
        its(:signed_in?) { should eq(false) }
        its(:agreed_to_application_terms_of_service?) { should eq(false) }

        it { should contractually_honor(Sipity::Interfaces::AuthenticationAgentInterface) }
      end
    end
  end
end
