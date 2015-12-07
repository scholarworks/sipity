require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/submit_advisor_portion_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe SubmitAdvisorPortionForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, requested_by: user, repository: repository } }
          subject { described_class.new(keywords) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:requested_by) }
          it { should validate_presence_of(:work) }

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          it { should delegate_method(:submit).to(:processing_action_form) }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }
        end
      end
    end
  end
end
