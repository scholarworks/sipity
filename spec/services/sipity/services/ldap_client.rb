require 'spec_helper'
module Sipity
  module Services
    RSpec.describe LdapClient do
      let(:ldap_options) do
        {
          host: 'directory.example.com',
          port: '636',
          encryption: :simple_tls,
          base: 'o="Example LLC", st=Indiana, c=US'
        }
      end
      context "#netid_valid?" do
        context "valid_user" do
          let(:user) { User.new(username: 'usr1') }
          let(:ldap_client) { LdapClient.new(user.username, ldap_options) }
          it "should return true" do
            LdapClient.any_instance.stub(:ldap_lookup).and_return(true)
            expect(ldap_client.netid_valid?).to be_truthy
          end
        end
        context "invalid_user" do
          let(:invalid_user) { User.new(username: 'inv_usr') }
          let(:ldap_client) { LdapClient.new(invalid_user.username, ldap_options) }
          it "should return true" do
            LdapClient.any_instance.stub(:ldap_lookup).and_return(nil)
            expect(ldap_client.netid_valid?).to be_falsey
          end
        end
      end

    end
  end
end
