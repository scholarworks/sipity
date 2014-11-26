require 'spec_helper'

module Sip
  RSpec.describe Header, type: :model do
    subject { Header.new }

    its(:possible_work_publication_strategies) { should eq(subject.class.work_publication_strategies) }

    context '.work_publication_strategies' do
      it 'is a Hash of keys that equal their values' do
        expect(Header.work_publication_strategies.keys).
          to eq(Header.work_publication_strategies.values)
      end
    end

    it 'has many :additional_attributes' do
      expect(Sip::Header.reflect_on_association(:additional_attributes)).
        to be_a(ActiveRecord::Reflection::AssociationReflection)
    end

    it 'has many :doi_creation_request' do
      expect(Sip::Header.reflect_on_association(:doi_creation_request)).
        to be_a(ActiveRecord::Reflection::AssociationReflection)
    end

    context '.accepts_nested_attributes_for collaborators' do
      it 'should not create a collaborator instance when no name is provided' do
        expect do
          # Using .create! so an exception is thrown. If the exception is thrown
          # it means validation fails.
          Header.create!(
            'title' => 'Hello World',
            'work_publication_strategy' => 'do_not_know',
            'collaborators_attributes' => { '0' => { 'name' => '' } }
          )
        end.to_not change { Collaborator.count }
      end
    end
  end
end
