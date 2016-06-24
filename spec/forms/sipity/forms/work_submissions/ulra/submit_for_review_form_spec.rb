require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/submit_for_review_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe SubmitForReviewForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, requested_by: user, repository: repository } }
          subject { described_class.new(keywords) }

          it 'validates the aggreement to the submission terms' do
            subject = described_class.new(keywords)
            subject.valid?
            expect(subject.errors[:agree_to_terms_of_deposit]).to be_present
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:agree_to_terms_of_deposit, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }
        end
      end
    end
  end
end
