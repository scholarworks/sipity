require 'spec_helper'
require 'sipity/forms/core/work_submissions/show_form'

module Sipity
  module Forms
    module Core
      module WorkSubmissions
        RSpec.describe ShowForm do
          let(:processing_action_name) { 'show' }
          let(:work) { double(id: 1) }
          subject { described_class.new(work: work, processing_action_name: processing_action_name) }

          its(:policy_enforcer) { should eq Sipity::Policies::WorkPolicy }
          its(:processing_action_name) { should eq processing_action_name }
          its(:work_id) { should eq work.id }
          it { should be_decorated }
          it { should be_a(Models::Work) }
        end
      end
    end
  end
end
