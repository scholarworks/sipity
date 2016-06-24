require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/submit_student_portion_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe SubmitStudentPortionForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, requested_by: user, repository: repository } }
          subject { described_class.new(keywords) }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:requested_by) }
          it { is_expected.to validate_presence_of(:work) }
          it { is_expected.to validate_acceptance_of(:agree_to_terms_of_deposit) }

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object', input: '')
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
