require 'spec_helper'

module Sip
  RSpec.describe HeaderDecorator do
    let(:header) { double(title: 'Hello World') }
    subject { HeaderDecorator.new(header) }
    it 'will have a #to_s equal its #title' do
      expect(subject.to_s).to eq(header.title)
    end

    let(:authors) { [double('Author')] }
    it 'will have #authors' do
      allow(Repo::Support::Collaborators).to receive(:for).with(header: header, role: 'author').and_return(authors)
      allow(CollaboratorDecorator).to receive(:decorate).with(authors[0])
      subject.authors
    end
  end
end
