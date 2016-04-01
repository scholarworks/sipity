require 'rails_helper'
require 'sipity/models/processing/entity_specific_responsibility'

module Sipity
  module Models
    module Processing
      RSpec.describe EntitySpecificResponsibility, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include('strategy_role_id') }
        its(:column_names) { is_expected.to include('entity_id') }
        its(:column_names) { is_expected.to include('actor_id') }
      end
    end
  end
end
