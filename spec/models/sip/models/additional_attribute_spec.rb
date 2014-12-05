require 'rails_helper'

module Sip
  module Models
    RSpec.describe AdditionalAttribute, type: :model do
      it 'belongs to :header' do
        expect(described_class.reflect_on_association(:header)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end
    end
  end
end
