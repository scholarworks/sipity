require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe BeginDataRemediationForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }

          it { should delegate_method(:submit).to(:processing_action_form) }

          its(:render) { should be_html_safe }
        end
      end
    end
  end
end
