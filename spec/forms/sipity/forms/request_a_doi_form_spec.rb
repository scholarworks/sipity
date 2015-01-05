require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe RequestADoiForm do
      let(:sip) { double('Sip') }
      subject { described_class.new(sip: sip) }

      it 'requires a sip' do
        subject = described_class.new(sip: nil)
        subject.valid?
        expect(subject.errors[:sip]).to_not be_empty
      end

      it 'requires an publisher' do
        subject.valid?
        expect(subject.errors[:publisher]).to_not be_empty
      end

      it 'requires an publication_date' do
        subject.valid?
        expect(subject.errors[:publication_date]).to_not be_empty
      end

      let(:authors) { [double('Author')] }
      it 'will have #authors' do
        allow(Queries::CollaboratorQueries).to receive(:sip_collaborators_for).
          with(sip: sip, role: 'author').and_return(authors)
        allow(Decorators::CollaboratorDecorator).to receive(:decorate).with(authors[0])
        subject.authors
      end
    end
  end
end
