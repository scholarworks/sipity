require 'rails_helper'
require 'sipity/models/processing/entity_action_register'

module Sipity
  module Models
    module Processing
      RSpec.describe EntityActionRegister, type: :model do
        context 'class configuration' do
          subject { described_class }
          its(:column_names) { should include("strategy_action_id") }
          its(:column_names) { should include("entity_id") }
          its(:column_names) { should include("on_behalf_of_identifier_id") }
          its(:column_names) { should include("requested_by_identifier_id") }
          its(:column_names) { should include("subject_id") }
          its(:column_names) { should include("subject_type") }
        end

        context 'conversions methods' do
          subject { described_class.new }
          it { should delegate_method(:proxy_for).to(:entity) }
          it { should respond_to :to_processing_action }
          it { should respond_to :to_processing_entity }
        end
      end
    end
  end
end
