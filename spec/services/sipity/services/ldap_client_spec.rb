require 'spec_helper'
module Sipity
  module Services
    RSpec.describe LdapClient do
      let(:ldap_options) do
        { host: 'directory.example.com', port: '636', encryption: :simple_tls, base: 'o="Example LLC", st=Indiana, c=US' }
      end
      context "#netid_valid?" do
        subject { LdapClient.new(ldap_options) }
        let(:netid) { 'a possible netid' }
        context 'with a valid netid' do
          it "will return true for a valid netid" do
            expect(subject).to receive(:ldap_entry_for).and_return(true)
            expect(subject.valid_netid?(netid)).to eq(true)
          end
        end
        context "with invalid net id" do
          it "should return false" do
            expect(subject).to receive(:ldap_entry_for).and_return(nil)
            expect(subject.valid_netid?(netid)).to eq(false)
          end
        end
      end
    end
  end
end
