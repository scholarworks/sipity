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

          context 'without valid data' do
            it 'will not save the form' do
              expect(subject).to receive(:valid?).and_return(false)
              expect(subject).to_not receive(:save)
              expect(subject.submit(requested_by: user)).to eq(false)
            end
          end

          context 'with valid data' do
            before do
              expect(subject).to receive(:valid?).and_return(true)
              allow(Services::RequestChangesViaCommentService).to receive(:call)
            end

            it 'will delegate to Services::RequestChangesViaCommentService' do
              expect(Services::RequestChangesViaCommentService).to receive(:call)
              subject.submit(requested_by: user)
            end

            it 'will return the work' do
              expect(subject.submit(requested_by: user)).to eq(work)
            end
          end
        end
      end
    end
  end
end
