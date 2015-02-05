require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe Strategy, type: :model do
        subject { described_class }
        its(:column_names) { should include('proxy_for_id') }
        its(:column_names) { should include('proxy_for_type') }
        its(:column_names) { should include('name') }
      end
    end
  end
end
