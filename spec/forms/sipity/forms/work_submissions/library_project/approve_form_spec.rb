require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/approve_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe ApproveForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, requested_by: user, repository: repository } }
          subject { described_class.new(keywords) }

          its(:render) { should be_html_safe }
          it { should delegate_method(:submit).to(:processing_action_form) }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }
        end
      end
    end
  end
end
