require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/respond_to_advisor_request_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RespondToAdvisorRequestForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords) }

          context '#render' do
            let(:form) { double }
            it 'will return an input text area' do
              expect(form).to receive(:input).with(:comment, hash_including(as: :text))
              subject.render(form: form)
            end
          end

          its(:input_legend) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }
          it { should implement_processing_form_interface }

          context 'with valid data' do
            before do
              expect(subject).to receive(:valid?).and_return(true)
              allow(Services::RequestChangesViaCommentService).to receive(:call)
            end

            it 'will delegate to Services::RequestChangesViaCommentService' do
              expect(Services::RequestChangesViaCommentService).to receive(:call)
              subject.submit
            end

            it 'will return the work' do
              expect(subject.submit).to eq(work)
            end
          end
        end
      end
    end
  end
end
