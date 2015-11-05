require 'rails_helper'
require 'sipity/models/additional_attribute'

module Sipity
  module Models
    RSpec.describe AdditionalAttribute, type: :model do
      it 'belongs to :work' do
        expect(described_class.reflect_on_association(:work)).
          to be_a(ActiveRecord::Reflection::AssociationReflection)
      end

      it 'will raise an ArgumentError if you provide an invalid key' do
        expect { subject.key = '__incorrect_strategy__' }.to raise_error(ArgumentError)
      end

      context '.scrubber_for' do
        described_class.keys.each do |predicate_name, _|
          it "will have exist for the #{predicate_name.inspect} predicate" do
            expect(described_class.scrubber_for(predicate_name: predicate_name)).to respond_to(:sanitize)
          end
        end
      end
    end
  end
end
