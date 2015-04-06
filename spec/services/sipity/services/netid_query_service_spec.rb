require 'spec_helper'

module Sipity
  module Services
    RSpec.describe NetidQueryService do
      let(:netid) { 'somenetid' }
      let(:full_name) { 'Full Name' }
      subject { described_class.new(netid) }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(netid: netid)
        end
      end

      context 'self.preferred_name' do
        it 'will get preferred_name for the given netid' do
          expect(described_class).to receive_message_chain(:new, :preferred_name).
            and_return(full_name)
          expect(described_class.preferred_name(netid: netid)).to eq(full_name)
        end
      end

      context 'self.valid_netid?' do
        it 'will validate netif for the given netid' do
          expect(described_class).to receive_message_chain(:new, :valid_netid?).
            and_return(netid)
          expect(described_class.valid_netid?(netid: netid)).to eq(netid)
        end
      end

      context 'preferred_name' do
        it 'will return false when the request returns a 404 status' do
          expect(subject).to receive(:open).and_raise(OpenURI::HTTPError.new('', ''))
          expect(subject.preferred_name).to eq(netid)
        end

        it 'will return false when the requested NetID is not found for a person'do
          expect(subject).to receive(:open).and_return(StringIO.new(valid_response_but_not_for_a_user))
          expect(subject.preferred_name).to eq(netid)
        end
        it 'will return the NetID when the document contains the NetID' do
          expect(subject).to receive(:open).and_return(StringIO.new(valid_response_with_netid))
          expect(subject.preferred_name).to eq('Bob the Builder')
        end
        it 'will raise an exception if the returned document is malformed' do
          expect(subject).to receive(:open).and_return(StringIO.new(invalid_document))
          expect { subject.preferred_name }.to raise_error(NoMethodError)
        end
      end

      context 'valid_netid?' do
        it 'will return false when the request returns a 404 status' do
          expect(subject).to receive(:open).and_raise(OpenURI::HTTPError.new('', ''))
          expect(subject.valid_netid?).to eq(false)
        end

        it 'will return false when the requested NetID is not found for a person'do
          expect(subject).to receive(:open).and_return(StringIO.new(valid_response_but_not_for_a_user))
          expect(subject.valid_netid?).to eq(false)
        end
        it 'will return the NetID when the document contains the NetID' do
          expect(subject).to receive(:open).and_return(StringIO.new(valid_response_with_netid))
          expect(subject.valid_netid?).to eq('a_netid')
        end
        it 'will raise an exception if the returned document is malformed' do
          expect(subject).to receive(:open).and_return(StringIO.new(invalid_document))
          expect { subject.valid_netid? }.to raise_error(NoMethodError)
        end
      end

      let(:valid_response_with_netid) do
        <<-DOCUMENT
        {
          "people":[
            {
              "id":"a_netid","identifier_contexts":{
                "ldap":"uid","staff_directory":"email"
              },"identifier":"by_netid","netid":"a_netid","first_name":"Bob","last_name":"the Builder", "full_name":"Bob the Builder"
            }
          ]
        }
        DOCUMENT
      end
      let(:valid_response_but_not_for_a_user) do
        <<-DOCUMENT
        {
          "people":[
            {
              "id":"a_netid","identifier_contexts":{
                "ldap":"uid","staff_directory":"email"
              },"identifier":"by_netid","contact_information":{}
            }
          ]
        }
        DOCUMENT
      end

      let(:invalid_document) do
        <<-DOCUMENT
        {
          "people": null
        }
        DOCUMENT
      end

    end
  end
end
