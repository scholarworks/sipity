require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe EntitySpecificResponsibility, type: :model do
        subject { described_class }
        its(:column_names) { should include('strategy_role_id') }
        its(:column_names) { should include('entity_id') }
        its(:column_names) { should include('actor_id') }
      end
    end
  end
end
