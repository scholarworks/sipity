require 'rails_helper'
require 'sipity/models/submission_window'

module Sipity
  module Models
    RSpec.describe SubmissionWindow, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { is_expected.to include('work_area_id') }
        its(:column_names) { is_expected.to include('slug') }
      end

      subject { described_class.new(slug: 'the-slug') }

      it { is_expected.to respond_to :processing_strategy }
      it { is_expected.to respond_to :processing_state }
      it { is_expected.to respond_to :work_area_slug }
      it { is_expected.to respond_to :work_area_partial_suffix }

      it 'will have many .submission_window_work_types' do
        expect(subject.submission_window_work_types).to be_a(ActiveRecord::Relation)
      end

      it 'will have one .strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end

      it 'will have one .work_submissions' do
        expect(subject.association(:work_submissions)).to be_a(ActiveRecord::Associations::HasManyAssociation)
      end

      context '#slug' do
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Hello World'
          expect(subject.slug).to eq('hello-world')
        end
      end

      its(:to_s) { is_expected.to eq(subject.slug) }

      context '#to_processing_entity' do
        it 'will raise an exception if one has not been created' do
          expect { subject.to_processing_entity }.to raise_error(Exceptions::ProcessingEntityConversionError)
        end
        it 'will return the existing process entity' do
          expect_processing_entity = subject.build_processing_entity
          expect(subject.to_processing_entity).to eq(expect_processing_entity)
        end
      end
    end
  end
end
