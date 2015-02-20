require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe EntityActionRegister, type: :model do
        subject { described_class }
        its(:column_names) { should include("strategy_action_id") }
        its(:column_names) { should include("entity_id") }
        its(:column_names) { should include("on_behalf_of_actor_id") }
        its(:column_names) { should include("requested_by_actor_id") }
      end
    end
  end
end
