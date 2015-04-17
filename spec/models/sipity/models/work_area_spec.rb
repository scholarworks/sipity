require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkArea, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('slug') }
        its(:column_names) { should include('partial_suffix') }
        its(:column_names) { should include('demodulized_class_prefix_name') }
      end

      subject { described_class.new }
      context '#slug' do
        # TODO: Consider using a slugging library as there are use cases that
        #   we may need to account for.
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Hello World'
          expect(subject.slug).to eq('hello-world')
        end
      end
    end
  end
end
