require "rails_helper"

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe DebugForm do
          let(:work) { double(id: true) }
          let(:processing_action_name) { 'debug' }
          subject { described_class.new(work: work, processing_action_name: processing_action_name) }
          its(:base_class) { is_expected.to eq(Models::Work) }
          its(:policy_enforcer) { is_expected.to eq(Sipity::Policies::WorkPolicy) }

          it { is_expected.to delegate_method(:work_id).to(:work).as(:id) }
        end
      end
    end
  end
end
