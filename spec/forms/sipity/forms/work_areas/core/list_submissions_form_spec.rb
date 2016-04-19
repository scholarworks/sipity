require 'spec_helper'
require 'sipity/forms/work_areas/core/list_submissions_form'

module Sipity
  module Forms
    module WorkAreas
      module Core
        RSpec.describe ListSubmissionsForm do
          let(:work_area) { double(name: 'Hello Name', slug: 'hello-world') }
          let(:repository) { QueryRepositoryInterface.new }
          let(:user) { double }
          subject { described_class.new(work_area: work_area, requested_by: user, repository: repository) }

          its(:policy_enforcer) { is_expected.to eq Sipity::Policies::WorkAreaPolicy }
          its(:processing_action_name) { is_expected.to eq('list_submissions') }
          it { is_expected.to implement_processing_form_interface }
          it { is_expected.to delegate_method(:to_json).to(:works) }
          it { is_expected.to delegate_method(:as_json).to(:works) }

          context '#works' do
            subject { described_class.new(work_area: work_area, requested_by: user, repository: repository).works }
            it { is_expected.to be_a(Enumerable) }
            it 'should be an Enumerable of Models::ExpandedWork objects' do
              work = Models::Work.new(id: '123')
              allow(repository).to receive(:find_works_via_search).and_return(work)
              expect(subject.first).to be_a(Models::ExpandedWork)
            end
          end
        end
      end
    end
  end
end
