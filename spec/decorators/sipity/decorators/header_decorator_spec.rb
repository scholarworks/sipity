require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe HeaderDecorator do
      let(:header) { Models::Header.new(title: 'Hello World') }
      subject { HeaderDecorator.new(header) }
      it 'will have a #to_s equal its #title' do
        expect(subject.to_s).to eq(header.title)
      end

      context '.fieldset_for' do
        it 'wrap the results of the block inside a fieldset tag' do
          expect(subject.fieldset_for('attributes') { 'hello' }).to match(%r{^<fieldset.*legend>hello</fieldset>})
        end
      end

      it 'shares .object_class with Models::Header' do
        expect(HeaderDecorator.object_class).to eq(Models::Header)
      end

      let(:authors) { [double('Author')] }
      it 'will have #authors' do
        allow(Repo::Support::Collaborators).to receive(:for).with(header: header, role: 'author').and_return(authors)
        allow(CollaboratorDecorator).to receive(:decorate).with(authors[0])
        subject.authors
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:title)).to eq('Title')
      end

      context '.with_recommendation' do
        it 'will yield a recommendation object based on input' do
          expect { |b| subject.with_recommendation('doi', &b) }.to yield_with_args(Recommendations::DoiRecommendation)
        end
      end
    end
  end
end
