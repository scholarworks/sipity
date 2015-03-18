require 'spec_helper'

module Sipity
  module Models
    RSpec.describe AccessRightFacade do
      let(:object) { Models::Work.new(id: 123) }
      let(:access_right) { Models::AccessRight.new(access_right_code: 'embargo_then_open_access', release_date: Date.today) }
      subject { described_class.new(object) }

      before { allow(Models::AccessRight).to receive(:find_or_initialize_by).and_return(access_right) }

      its(:id) { should eq(object.id) }
      its(:persisted?) { should eq(object.persisted?) }
      its(:to_s) { should eq(object.to_s) }
      its(:entity_id) { should eq(subject.id) }
      its(:to_param) { should eq(object.to_param) }
      its(:entity_type) { should eq(Sipity::Models::Work) }
      its(:access_right_code) { should eq(access_right.access_right_code) }
      its(:release_date) { should eq(access_right.release_date) }
      it { should respond_to :access_url }

      it 'will leverage the access right to translate human_attribute_name' do
        expect(subject.human_attribute_name(:title)).to eq('Title')
      end

      context '#access_url' do
        it 'will be a file url if one is given' do
          object = Models::Attachment.new(file: __FILE__)
          subject = described_class.new(object)
          expect(subject.access_url).to eq(object.file_url)
        end

        it 'will be a resolve polymorphic path for a Models::Work' do
          allow(object).to receive(:persisted?).and_return(true)
          subject = described_class.new(object)
          expect(subject.access_url).to match(%r{^https?://[^/]*/works/#{object.id}$})
        end
      end
    end
  end
end
