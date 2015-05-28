require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe GradSchoolRequestsChangeForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { User.new(id: 1) }
          subject { described_class.new(work: work, repository: repository) }

          its(:processing_action_name) { should eq('grad_school_requests_change') }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          it { should_not be_persisted }

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
            its(:grad_school_requests_change_legend) { should be_html_safe }
          end

          context 'with valid data' do
            let(:processing_comment) { double('Processing Comment') }
            let(:an_action) { double }
            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              allow(repository).to receive(:record_processing_comment).and_return(processing_comment)
              allow(subject).to receive(:convert_to_processing_action).and_return(an_action)
            end

            it 'will send creating user a note that the advisor has requested changes' do
              expect(repository).to receive(:deliver_notification_for).
                with(scope: an_action, the_thing: processing_comment, requested_by: user).
                and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the processing comment' do
              expect(repository).to receive(:record_processing_comment).and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
