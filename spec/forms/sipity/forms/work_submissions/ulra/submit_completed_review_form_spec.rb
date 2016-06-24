require "rails_helper"

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe SubmitCompletedReviewForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }

          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }

          its(:render) { is_expected.to be_html_safe }
        end
      end
    end
  end
end
