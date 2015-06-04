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

        context 'an instance' do
          subject { described_class.new }
          it { should respond_to(:processing_state) }
          it { should respond_to(:processing_strategy) }
          it { shoulde delegate_method(:strategy_state_name).to(:strategy_state).as(:name) }
          it { shoulde delegate_method(:strategy_name).to(:strategy).as(:name) }
        end
      end
    end
  end
end
