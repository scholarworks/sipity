require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Group, type: :model do
      subject { described_class.new }
      its(:valid?) { should be false }
      it 'has many :permissions' do
        expect(described_class.reflect_on_association(:permissions)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end
    end
  end
end
