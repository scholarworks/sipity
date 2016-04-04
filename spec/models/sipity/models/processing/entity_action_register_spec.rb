require 'rails_helper'
require 'sipity/models/processing/entity_action_register'

module Sipity
  module Models
    module Processing
      RSpec.describe EntityActionRegister, type: :model do
        context 'class configuration' do
          subject { described_class }
          its(:column_names) { is_expected.to include("strategy_action_id") }
          its(:column_names) { is_expected.to include("entity_id") }
          its(:column_names) { is_expected.to include("on_behalf_of_actor_id") }
          its(:column_names) { is_expected.to include("requested_by_actor_id") }
          its(:column_names) { is_expected.to include("subject_id") }
          its(:column_names) { is_expected.to include("subject_type") }
        end

        context 'conversions methods' do
          subject { described_class.new }
          it { is_expected.to delegate_method(:proxy_for).to(:entity) }
          it { is_expected.to respond_to :to_processing_action }
          it { is_expected.to respond_to :to_processing_entity }
        end
      end
    end
  end
end
