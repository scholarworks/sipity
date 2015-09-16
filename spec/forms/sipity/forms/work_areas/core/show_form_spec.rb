require 'spec_helper'
require 'sipity/forms/work_areas/core/show_form'
require 'sipity/forms/work_areas/core/show_form'

module Sipity
  module Forms
    module WorkAreas
      module Core
        RSpec.describe ShowForm do
          let(:work_area) { double(name: 'Hello Name', slug: 'hello-world') }
          let(:repository) { QueryRepositoryInterface.new }
          let(:user) { double }
          subject { described_class.new(work_area: work_area, requested_by: user, repository: repository) }

          its(:policy_enforcer) { should eq Sipity::Policies::WorkAreaPolicy }
          its(:processing_action_name) { should eq('show') }
          it { should implement_processing_form_interface }
          it { should delegate_method(:name).to(:work_area) }
          it { should delegate_method(:slug).to(:work_area) }

          its(:order_options_for_select) { should be_a(Array) }
          its(:input_name_for_select_processing_state) { should eq('work_area[processing_state]') }
          its(:input_name_for_select_sort_order) { should eq('work_area[order]') }
          its(:page) { should eq(subject.send(:default_page)) }

          it { should delegate_method(:default_order).to(:search_criteria_config) }
          it { should delegate_method(:default_page).to(:search_criteria_config) }
          it { should delegate_method(:order_options_for_select).to(:search_criteria_config) }

          it 'will expose #processing_states_for_select' do
            expect(repository).to receive(:processing_state_names_for_select_within_work_area).with(work_area: work_area).and_call_original
            subject.processing_states_for_select
          end
        end
      end
    end
  end
end
