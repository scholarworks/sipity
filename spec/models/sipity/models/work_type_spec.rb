require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkType, type: :model do
      context 'work type constants' do
        [:ULRA_SUBMISSION, :MASTER_THESIS, :DOCTORAL_DISSERTATION].each do |constant_name|
          it "will expose #{constant_name}" do
            expect(described_class.const_get(constant_name)).to be_a(String)
          end
        end
      end
      context '.[]' do
        it 'will have an ETD' do
          described_class.create!(name: 'doctoral_dissertation')
          expect(described_class['doctoral_dissertation']).to be_a(WorkType)
        end

        it 'will raise an exception if the WorkType is invalid' do
          expect { described_class['__MISSIN__'] }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it 'will have many .submission_window_work_types' do
        expect(subject.submission_window_work_types).to be_a(ActiveRecord::Relation)
      end

      context '.all_for_enum_configuration' do
        it 'will be a Hash to appease the enum interface' do
          expect(described_class.all_for_enum_configuration).to be_a(Hash)
        end
      end

      context '.valid_names' do
        it 'will be an Array' do
          expect(described_class.valid_names).to be_a(Array)
        end
      end

      it 'has one :strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end
    end
  end
end
