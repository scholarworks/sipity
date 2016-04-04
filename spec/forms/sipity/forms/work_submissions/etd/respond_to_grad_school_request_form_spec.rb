require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/respond_to_grad_school_request_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RespondToGradSchoolRequestForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords) }

          context '#render' do
            let(:f) { double }
            it 'will return an input text area' do
              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              subject.render(f: f)
            end
          end

          its(:input_legend) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'without valid data' do
            it 'will not save the form' do
              expect(subject).to receive(:valid?).and_return(false)
              expect(Services::RequestChangesViaCommentService).to_not receive(:call)
              expect(subject.submit).to eq(false)
            end
          end

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
