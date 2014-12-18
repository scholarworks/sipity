require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe RequestADoiForm do
      let(:header) { double('Header') }
      subject { described_class.new(header: header) }

      it 'requires a header' do
        subject = described_class.new(header: nil)
        subject.valid?
        expect(subject.errors[:header]).to_not be_empty
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
        allow(RepositoryMethods::CollaboratorMethods::Queries).to receive(:header_collaborators_for).
          with(header: header, role: 'author').and_return(authors)
        allow(Decorators::CollaboratorDecorator).to receive(:decorate).with(authors[0])
        subject.authors
      end
    end
  end
end
