require 'spec_helper'
require 'sipity/forms/core/work_areas/show_form'

module Sipity
  module Forms
    module Core
      module WorkAreas
        RSpec.describe ShowForm do
          let(:processing_action_name) { 'show' }
          let(:work_area) { double }
          subject { described_class.new(work_area: work_area, processing_action_name: processing_action_name) }

          its(:policy_enforcer) { should eq Sipity::Policies::WorkAreaPolicy }
          its(:processing_action_name) { should eq processing_action_name }

          it { expect(subject.is_a?(Models::WorkArea)).to be_truthy }
        end
      end
    end
  end
end
