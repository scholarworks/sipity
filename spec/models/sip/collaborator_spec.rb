require 'spec_helper'
module Sip
  RSpec.describe Collaborator, type: :model do
    it 'defaults the role' do
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
  end
end
