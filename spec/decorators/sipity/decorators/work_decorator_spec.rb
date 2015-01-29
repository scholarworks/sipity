require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe WorkDecorator do
      let(:work) { Models::Work.new(title: 'Hello World', id: 123) }
      subject { WorkDecorator.new(work) }
      it 'will have a #to_s equal its #title' do
        expect(subject.to_s).to eq(work.title)
      end

      context '#each_todo_item_set' do
        # TODO: Because I'm now driving from a persistence layer; This will require
        # reworking.
        xit 'will be an enumerable' do
          expect { |b| subject.each_todo_item_set(&b) }.to yield_with_args('required', Set)
        end
      end

      context '#available_linked_actions' do
        context 'for a null user' do
          it 'will be an empty array' do
            expect(subject.available_linked_actions(user: nil)).to be_empty
          end
        end
        context 'for a current_user' do
          let(:user) { double('User') }
          it 'will return an enumerable in which all elements responds to render' do
            expect(subject.available_linked_actions(user: user)).to_not be_empty
          end
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

      context '#with_action_pane' do
        it 'wrap the results of the block inside an action pane' do
          rendered = subject.with_action_pane('actions') { 'submit' }
          expect(rendered).to have_tag('.action-pane', content: 'submit')
        end
      end

      it 'shares .object_class with Models::Work' do
        expect(WorkDecorator.object_class).to eq(Models::Work)
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
