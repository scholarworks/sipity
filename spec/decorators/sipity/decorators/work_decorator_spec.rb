require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe SipDecorator do
      let(:work) { Models::Work.new(title: 'Hello World', id: 123) }
      subject { SipDecorator.new(work) }
      it 'will have a #to_s equal its #title' do
        expect(subject.to_s).to eq(work.title)
      end

      context '#available_linked_actions' do
        it 'will return an enumerable in which all elements responds to render' do
          expect(subject.available_linked_actions.all? { |link| link.respond_to?(:render) }).to be_truthy
        end
      end

      context '#with_form_panel' do
        it 'wrap the results of the block inside a panel' do
          rendered = subject.with_form_panel('attributes') { 'hello' }
          expect(rendered).to have_tag('.panel') do
            with_tag('.panel-heading .panel-title')
            with_tag('.panel-body', text: /hello/)
          end
        end
      end

      it 'shares .object_class with Models::Sip' do
        expect(SipDecorator.object_class).to eq(Models::Sip)
      end

      let(:authors) { [double('Author')] }
      it 'will have #authors' do
        allow(Queries::CollaboratorQueries).to receive(:work_collaborators_for).
          with(work: work, role: 'author').and_return(authors)
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
