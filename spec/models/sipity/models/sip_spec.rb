require 'spec_helper'

module Sipity
  module Models
    RSpec.describe Sip, type: :model do
      subject { Sip.new }

      context 'database columns' do
        subject { Sip }
        its(:column_names) { should include('processing_state') }
        its(:column_names) { should include('work_type') }
        its(:column_names) { should include('work_publication_strategy') }
        its(:column_names) { should include('title') }
      end

      context '.work_types' do
        it 'is a Hash of keys that equal their values' do
          expect(Sip.work_types.keys).
            to eq(Sip.work_types.values)
        end
      end

      context '#work_type' do
        it 'will raise an ArgumentError if you provide an invalid work_type' do
          expect { subject.work_type = '__incorrect_work_type__' }.to raise_error(ArgumentError)
        end

        it 'accepts "ETD" as an acceptable work_type' do
          expect { subject.work_type = 'ETD' }.to_not raise_error
        end
      end

      its(:possible_work_publication_strategies) { should eq(subject.class.work_publication_strategies) }

      context '.work_publication_strategies' do
        it 'is a Hash of keys that equal their values' do
          expect(Sip.work_publication_strategies.keys).
            to eq(Sip.work_publication_strategies.values)
        end
      end

      it 'will raise an ArgumentError if you provide an invalid work_publication_strategy' do
        expect { subject.work_publication_strategy = '__incorrect_strategy__' }.to raise_error(ArgumentError)
      end

      it 'has many :additional_attributes' do
        expect(Sip.reflect_on_association(:additional_attributes)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'has one :doi_creation_request' do
        expect(Sip.reflect_on_association(:doi_creation_request)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      context '.accepts_nested_attributes_for collaborators' do
        it 'should not create a collaborator instance when no name is provided' do
          expect do
            # Using .create! so an exception is thrown. If the exception is thrown
            # it means validation fails.
            Sip.create!(
              'title' => 'Hello World',
              'work_publication_strategy' => 'do_not_know',
              'collaborators_attributes' => { '0' => { 'name' => '' } }
            )
          end.to_not change { Collaborator.count }
        end
      end
    end
  end
end
