require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RespondToGradSchoolRequestForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { User.new(id: 1) }
          subject { described_class.new(work: work, repository: repository) }

          context '#render' do
            let(:f) { double }
            it 'will return an input text area' do
              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              subject.render(f: f)
            end
          end

          its(:input_legend) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'with valid data' do
            let(:an_action) { double }
            let(:a_processing_comment) { double }
            before do
              allow(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
              allow(subject).to receive(:convert_to_processing_action).and_return(an_action)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will send creating user a note that the advisor has requested changes' do
              expect(repository).to receive(:deliver_notification_for).
                with(scope: an_action, the_thing: a_processing_comment, requested_by: user).
                and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the processing comment' do
              expect(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
