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

      let(:decorator) { double(decorate: :decorated) }
      it 'will build a decorated header if decoration is requested' do
        allow(Header).to receive(:find).with('8675309').and_return(:found)
        expect(subject.find_header('8675309', decorator: decorator)).to eq(:decorated)
        expect(decorator).to have_received(:decorate).with(:found)
      end
    end

    context '#build_header' do
      let(:decorator) { double(decorate: :decorated) }
      it 'will build a header without decoration' do
        expect(subject.build_header).to be_a(Header)
      end
      it 'will build a decorated header if decoration is requested' do
        expect(subject.build_header(decorator: decorator)).to eq(:decorated)
        expect(decorator).to have_received(:decorate).with(kind_of(Header))
      end
    end

    it { should respond_to :doi_request_is_pending? }
    it { should respond_to :doi_already_assigned? }
  end
end
