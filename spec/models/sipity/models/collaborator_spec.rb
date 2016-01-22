require 'spec_helper'
require 'sipity/models/collaborator'
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

      it 'belongs to :user' do
        expect(described_class.reflect_on_association(:user)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      context '.roles' do
        it 'is a Hash of keys that equal their values' do
          expect(Collaborator.roles.keys).
            to eq(Collaborator.roles.values)
        end
      end

      context '#to_processing_actor' do
        subject { described_class.new(id: 1) }
        let(:processing_actor) { double('Actor') }
        let(:user) { double('User') }
        it 'will retrieve processing actor of the user if one is present' do
          allow(subject).to receive(:user).and_return(user)
          expect(subject).to receive(:convert_to_processing_actor).and_return(processing_actor)
          expect(subject.to_processing_actor).to eq(processing_actor)
        end
        it 'will fall back on the existing processing actor if a user is not present' do
          expect(subject).to receive(:processing_actor).and_return(processing_actor)
          expect(subject).to receive(:user).and_return(nil)
          expect(subject.to_processing_actor).to eq(processing_actor)
        end
        it 'will fall back on the collaborator if no processing actor nor user is present' do
          allow(subject).to receive(:processing_actor).and_return(nil)
          allow(subject).to receive(:user).and_return(nil)
          expect(subject).to receive(:create_processing_actor!)
          subject.to_processing_actor
        end
      end

      context 'validations' do
        subject { described_class.new(role: 'Committee Member', name: 'Jeremy', responsible_for_review: false) }
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

        it 'will not allow an @nd.edu email address' do
          subject.email = 'hello@nd.edu'
          subject.valid?
          expect(subject.errors[:email]).to be_present
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
            expect(subject.valid?).to be_truthy
          end
        end
      end

      it 'will have a #to_s that is its #name' do
        subject.name = 'Hello World'
        expect(subject.to_s).to eq(subject.name)
      end

      it 'will raise an ArgumentError if you provide an invalid role' do
        expect { subject.role = '__incorrect_role__' }.to raise_error(ArgumentError)
      end

      it 'will nullify the email and netid' do
        subject = described_class.new(netid: '', email: '')
        subject.send(:nilify_blank_values)
        expect(subject.email).to be_nil
        expect(subject.netid).to be_nil
      end
    end
  end
end
