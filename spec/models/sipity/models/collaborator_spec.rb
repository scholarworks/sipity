require 'spec_helper'
module Sipity
  module Models
    RSpec.describe Collaborator, type: :model do
      it 'can build a default' do
        expect(Collaborator.build_default).to be_a(Collaborator)
      end

      it 'belongs to :work' do
        expect(described_class.reflect_on_association(:work)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      context '.roles' do
        it 'is a Hash of keys that equal their values' do
          expect(Collaborator.roles.keys).
            to eq(Collaborator.roles.values)
        end
      end

      context 'validations' do
        subject { described_class.new(role: 'author', name: 'Jeremy', responsible_for_review: false) }
        it 'will require a role' do
          subject.role = nil
          subject.valid?
          expect(subject.errors[:role]).to be_present
        end
        it 'will require a name' do
          subject.name = nil
          subject.valid?
          expect(subject.errors[:name]).to be_present
        end

        context 'when responsible for review' do
          it 'will have errors on netid and email if none are given' do
            subject.responsible_for_review = true
            subject.valid?
            expect(subject.errors[:email]).to be_present
            expect(subject.errors[:netid]).to be_present
            expect(subject.errors[:responsible_for_review]).to be_present
          end

          it 'will not have errors on netid and email one (or both) are given' do
            subject.responsible_for_review = true
            subject.email = 'hello@test.com'
            subject.netid = 'netid'
            expect(subject.valid?).to be_truthy
          end
        end
      end

      its(:possible_roles) { should eq(described_class.roles) }

      it 'will raise an ArgumentError if you provide an invalid role' do
        expect { subject.role = '__incorrect_role__' }.to raise_error(ArgumentError)
      end
    end
  end
end
