require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/grad_school_final_signoff_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe GradSchoolFinalSignoffForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: {} } }
          subject { described_class.new(**keywords) }

          context 'validation' do
            it 'will require agreement to the signoff' do
              expect(described_class.new(**keywords)).to be_valid
            end
          end

          context '#render' do
            it 'will render HTML safe legend' do
              form_object = double('Form Object')
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }
        end
      end
    end
  end
end
