require 'rails_helper'

module Sipity
  module Models
    RSpec.describe SubmissionWindow, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('work_area_id') }
        its(:column_names) { should include('slug') }
      end

      subject { described_class.new }

      it { should respond_to :processing_strategy }
      it { should respond_to :processing_state }

      it 'will have many .submission_window_work_types' do
        expect(subject.submission_window_work_types).to be_a(ActiveRecord::Relation)
      end

      it 'will have one .strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end

      context '#slug' do
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Hello World'
          expect(subject.slug).to eq('hello-world')
        end
      end

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
