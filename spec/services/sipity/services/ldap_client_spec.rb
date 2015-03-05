require 'spec_helper'
module Sipity
  module Services
    RSpec.describe LdapClient do
      let(:ldap_options) do
        { host: 'directory.example.com', port: '636', encryption: :simple_tls }
      end
      context "#netid_valid?" do
        subject { LdapClient.new(ldap_options) }
        let(:netid) { 'a possible netid' }
        context 'with a valid netid' do
          it "will return true for a valid netid" do
            expect(subject.connection).to receive(:search).and_return(true)
            expect(subject.valid_netid?(netid)).to eq(true)
          end
        end
        context "with invalid net id" do
          it "should return false" do
            expect(subject.connection).to receive(:search).and_return(false)
            expect(subject.valid_netid?(netid)).to eq(false)
          end
        end
      end
    end
  end
end
