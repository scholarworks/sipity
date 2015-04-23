require 'rails_helper'

module Sipity
  module Models
    RSpec.describe ApplicationConcept, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('slug') }
        its(:column_names) { should include('name') }
        its(:column_names) { should include('class_name') }
      end

      subject { described_class.new }

      context '#slug' do
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Areas'
          expect(subject.slug).to eq('areas')
        end
      end

      context '#class_name' do
        it 'will raise an ArgumentError if you provide an invalid name' do
          expect { subject.class_name = '__incorrect_name__' }.to raise_error(ArgumentError)
        end

        it 'will be a controlled vocabulary' do
          subject.class_name = 'Sipity::Models::WorkArea'
          expect(subject.class_name).to eq('Sipity::Models::WorkArea')
        end
      end
    end
  end
end
