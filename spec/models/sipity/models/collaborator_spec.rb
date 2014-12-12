require 'spec_helper'
module Sipity
  module Models
    RSpec.describe Collaborator, type: :model do
      it 'can build a default' do
        expect(Collaborator.build_default).to be_a(Collaborator)
      end

      it 'belongs to :header' do
        expect(described_class.reflect_on_association(:header)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      context '.roles' do
        it 'is a Hash of keys that equal their values' do
          expect(Collaborator.roles.keys).
            to eq(Collaborator.roles.values)
        end
      end

      its(:possible_roles) { should eq(described_class.roles) }

      it 'will raise an ArgumentError if you provide an invalid role' do
        expect { subject.role = '__incorrect_role__' }.to raise_error(ArgumentError)
      end
    end
  end
end
