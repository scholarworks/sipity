require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/grad_school_requests_change_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe GradSchoolRequestsChangeForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { User.new(id: 1) }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { is_expected.to eq('grad_school_requests_change') }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          it { is_expected.not_to be_persisted }
          it { is_expected.to implement_processing_form_interface }

          it 'will validate the presence of the :comment' do
            subject.valid?
            expect(subject.errors[:comment]).to be_present
          end

          context '#render' do
            let(:f) { double }
            it 'will return an input text area' do
              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              subject.render(f: f)
            end
            its(:grad_school_requests_change_legend) { is_expected.to be_html_safe }
          end

          context 'without valid data' do
            it 'will not save the form' do
              expect(subject).to receive(:valid?).and_return(false)
              expect(subject).to_not receive(:save)
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
