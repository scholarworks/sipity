require 'spec_helper'

module Sipity
  module Services
    RSpec.describe RemoteNetidValidator do
      subject { described_class }
      it 'will delegate validation to the netid_query_service' do
        netid = double
        expect(Services::NetidQueryService).to receive(:valid_netid?).with(netid: netid).and_return(true)
        expect(subject.valid_netid?(netid)).to eq(true)
      end
    end
  end
end
