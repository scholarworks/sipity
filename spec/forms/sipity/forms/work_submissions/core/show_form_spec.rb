require 'spec_helper'
require 'sipity/forms/work_submissions/core/show_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe ShowForm do
          let(:processing_action_name) { 'show' }
          let(:work) { Models::Work.new(id: 1) }
          subject { described_class.new(work: work, processing_action_name: processing_action_name) }

          its(:policy_enforcer) { is_expected.to eq Sipity::Policies::WorkPolicy }
          its(:processing_action_name) { is_expected.to eq processing_action_name }
          its(:work_id) { is_expected.to eq work.id }
          it { is_expected.to be_decorated }
          it { is_expected.to be_a(Models::Work) }
          its(:expanded_work) { is_expected.to be_a(Models::ExpandedWork) }

          it { is_expected.to delegate_method(:as_json).to(:expanded_work) }
          it { is_expected.to delegate_method(:to_json).to(:expanded_work) }
          it { is_expected.to delegate_method(:to_hash).to(:expanded_work) }
        end
      end
    end
  end
end
