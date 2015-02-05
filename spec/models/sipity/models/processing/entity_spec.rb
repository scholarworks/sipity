require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe Entity, type: :model do
        subject { described_class }
        its(:column_names) { should include("proxy_for_id") }
        its(:column_names) { should include("proxy_for_type") }
        its(:column_names) { should include("strategy_id") }
        its(:column_names) { should include("strategy_state_id") }
      end
    end
  end
end
