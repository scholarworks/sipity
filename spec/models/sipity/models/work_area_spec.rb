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
    end
  end
end
