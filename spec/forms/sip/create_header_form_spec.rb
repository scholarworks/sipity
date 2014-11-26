require 'spec_helper'

module Sip
  RSpec.describe CreateHeaderForm do
    subject { described_class.new }

    it 'will have a #possible_work_publication_strategies' do
      expect(subject.possible_work_publication_strategies).to be_a(Hash)
    end

    it 'will have a model name like Header' do
      expect(described_class.model_name).to be_a(ActiveModel::Name)
    end

    context 'validations for' do
      context '#contributors' do
        it '#role must be present' do
          # Adhearing to the ActiveRecord::Base.accepts_nested_attributes_for
          # interface
          subject.collaborators_attributes = { '0' => { name: 'Hello', role: '' } }
          expect(subject.valid?).to be_falsey
          expect(subject.collaborators[0].errors[:role]).to be_present
        end
        it '#role must be on the approved list' do
          # The enum enforcement is aggressive throwing an exception
          expect do
            subject.collaborators_attributes = { '0' => { name: 'Hello', role: '__missing__' } }
          end.to raise_error(ArgumentError)
        end
      end
      context '#title' do
        it 'must be present' do
          subject.valid?
          expect(subject.errors[:title]).to be_present
        end
      end
      context '#work_publication_strategy' do
        it 'must be present' do
          subject.valid?
          expect(subject.errors[:work_publication_strategy]).to be_present
        end
        it 'must be from the approved list' do
          subject.work_publication_strategy = '__missing__'
          subject.valid?
          expect(subject.errors[:work_publication_strategy]).to be_present
        end
      end
      context '#publication_date' do
        it 'must be present when it was :already_published' do
          subject.work_publication_strategy = 'already_published'
          subject.valid?
          expect(subject.errors[:publication_date]).to be_present
        end
        it 'need not be present otherwise' do
          subject.valid?
          expect(subject.errors[:publication_date]).to_not be_present
        end
      end
    end
  end
end
