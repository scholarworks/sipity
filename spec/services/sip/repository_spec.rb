require 'rails_helper'

module Sip
  RSpec.describe Repository, type: :repository do
    subject { Repository.new }
    context '#find_header' do
      it 'raises an exception if nothing is found' do
        expect { subject.find_header('8675309') }.to raise_error
      end

      it 'returns the Header when the object is found' do
        allow(Header).to receive(:find).with('8675309').and_return(:found)
        expect(subject.find_header('8675309')).to eq(:found)
      end
    end

    it { should respond_to :doi_request_is_pending? }
    it { should respond_to :doi_already_assigned? }
  end
end
