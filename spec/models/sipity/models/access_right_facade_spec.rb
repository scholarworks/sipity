require "rails_helper"
require 'sipity/models/access_right_facade'

module Sipity
  module Models
    RSpec.describe AccessRightFacade do
      let(:object) { work }
      let(:work) { Models::Work.new(id: 123, title: 'dummy') }
      let(:attachment) { Models::Attachment.new(id: 234, predicate_name: 'chicken') }
      let(:access_right) { Models::AccessRight.new(access_right_code: 'embargo_then_open_access', release_date: Time.zone.today) }
      subject { described_class.new(object, work: work) }

      before { allow(Models::AccessRight).to receive(:find_or_initialize_by).and_return(access_right) }

      its(:id) { is_expected.to eq(object.id) }
      its(:persisted?) { is_expected.to eq(object.persisted?) }
      its(:to_s) { is_expected.to eq(object.to_s) }
      its(:entity_id) { is_expected.to eq(subject.id) }
      its(:to_param) { is_expected.to eq(object.to_param) }
      its(:entity_type) { is_expected.to eq(Sipity::Models::Work) }
      its(:access_right_code) { is_expected.to eq(access_right.access_right_code) }
      its(:release_date) { is_expected.to eq(access_right.release_date) }

      its(:model_name) { is_expected.to eq(work.class.model_name) }
      its(:human_model_name) { is_expected.to eq(work.class.model_name.human) }

      it 'will leverage the access right to translate human_attribute_name' do
        expect(subject.send(:translator)).
          to receive(:call).with(scope: 'access_rights', object: :title, subject: object, predicate: 'label')
        subject.translate(:title)
      end

      context 'with prepopulation of access right information' do
        let(:object) { attachment }
        let(:work_access_right) { Models::AccessRight.new(access_right_code: 'embargo_then_open_access', release_date: Time.zone.today) }
        let(:access_right) { Models::AccessRight.new }
        it "will default an accessible object without a code to have the work's access right" do
          expect(Models::AccessRight).to receive(:find_or_initialize_by).
            with(hash_including(entity_id: object.id)).and_return(access_right)
          expect(Models::AccessRight).to receive(:find_or_initialize_by).
            with(hash_including(entity_id: work.id)).and_return(work_access_right)
          expect(subject.access_right_code).to eq(work_access_right.access_right_code)
          expect(subject.release_date).to eq(work_access_right.release_date)
        end

        it "will use the defined accessible object without a code to have the work's access right" do
          access_right.access_right_code = 'open_access'
          expect(Models::AccessRight).to receive(:find_or_initialize_by).
            with(hash_including(entity_id: object.id)).and_return(access_right)
          expect(Models::AccessRight).to_not receive(:find_or_initialize_by).with(hash_including(entity_id: work.id))
          expect(subject.access_right_code).to_not eq(work_access_right.access_right_code)
          expect(subject.release_date).to_not eq(work_access_right.release_date)
        end
      end

      context '#accessible_object_type' do
        it 'will include the object predicate name if one exists' do
          subject = described_class.new(attachment, work: work)
          expect(subject.accessible_object_type).to eq(attachment.predicate_name.titleize)
        end
        it 'will use the human_model_name if no predicate name exists' do
          expect(subject.accessible_object_type).to eq(subject.human_model_name)
        end
      end

      context '#access_url' do
        it 'will be a file url if one is given' do
          object = Models::Attachment.new(file: __FILE__)
          allow(object).to receive(:file_url).and_return('http://somewhere.com/hello/world')
          subject = described_class.new(object, work: work)
          expect(subject.access_url).to eq(object.file_url)
        end

        it 'will be a resolve polymorphic path for a Models::Work' do
          allow(object).to receive(:persisted?).and_return(true)
          subject = described_class.new(object, work: work)
          expect(subject.access_url).to match(%r{^https?://[^/]*/work_submissions/#{object.id}$})
        end
      end
    end
  end
end
