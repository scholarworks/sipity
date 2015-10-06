require 'spec_helper'
require 'sipity/decorators/work_decorator'

module Sipity
  module Decorators
    RSpec.describe WorkDecorator do
      let(:work) { Models::Work.new(title: 'Hello World', id: 123, created_at: Time.zone.now) }
      let(:repository) { QueryRepositoryInterface.new }
      subject { WorkDecorator.new(work, repository: repository) }
      it 'will have a #to_s equal its #title' do
        expect(subject.to_s).to eq(work.title)
      end

      its(:date_created) { should be_a(String) }
      its(:title) { should be_html_safe }

      context '#creators and #creator_names' do
        let(:creators) { [double(name: 'Hello')] }
        it 'will retrieve them from the underlying repository' do
          expect(repository).to receive(:scope_creating_users_for_entity).and_return(creators)
          expect(subject.creators).to eq(creators)
        end
        it 'will retrieve them from the underlying repository' do
          expect(repository).to receive(:scope_creating_users_for_entity).and_return(creators)
          expect(subject.creator_names).to eq(['Hello'])
        end
      end

      it 'shares .object_class with Models::Work' do
        expect(WorkDecorator.object_class).to eq(Models::Work)
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:title)).to eq('Title')
      end

      it 'will have #accessible_objects' do
        accessible_objects = [double, double]
        expect(repository).to receive(:access_rights_for_accessible_objects_of).with(work: work).and_return(accessible_objects)
        expect(subject.accessible_objects).to eq(accessible_objects)
      end

      let(:comment) { Sipity::Models::Processing::Comment.new }
      its(:current_comments) do
        expect(repository).to receive(:find_current_comments_for).with(entity: work).and_return(comment)
        should be_a(Enumerable)
      end
      its(:comments) do
        expect(repository).to receive(:find_comments_for).with(entity: work).and_return(comment)
        should be_a(Enumerable)
      end

      context "#selected_copyright" do
        let(:term_uri) { "http://creativecommons.org/licenses/by/3.0/us/" }
        let(:term_label) { "Attribution 3.0 United States" }
        let(:copyright_link) { "<a href=\"#{term_uri}\">#{term_label}</a>" }
        it 'will have #selected_copyrights' do
          expect(repository).to receive(:get_controlled_vocabulary_value_for).
            with(name: 'copyright', term_uri: term_uri).
            and_return(term_label)
          expect(subject.selected_copyright(term_uri)).to eq(copyright_link)
        end
      end

      xit '#state_advancing_actions is missing'
      xit '#resourceful_actions is missing'
      xit '#enrichment_actions is missing'
    end
  end
end
