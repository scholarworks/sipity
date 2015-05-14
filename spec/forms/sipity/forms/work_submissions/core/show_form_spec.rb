require 'spec_helper'
require 'sipity/forms/work_submissions/core/show_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
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
