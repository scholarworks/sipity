require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/reject_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe RejectForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:attributes) { { project_proposal_decision: 'I really dislike chicken' } }
          let(:keywords) { { work: work, requested_by: user, repository: repository, attributes: attributes } }
          subject { described_class.new(keywords) }

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object', input: '')
              expect(subject.render(f: form_object)).to be_html_safe
              expect(form_object).to have_received(:input).
                with(:project_proposal_decision, as: :text, input_html: { class: 'form-control' })
            end
          end

          it { should delegate_method(:submit).to(:processing_action_form) }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:project_proposal_decision) }

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              its(:submit) { should eq(false) }
            end
            context 'with valid data' do
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield.and_return(work)
              end
              its(:submit) { should eq(work) }

              it 'will create a jira issue' do
                expect(repository).to receive(:create_jira_issue_for).with(entity: work, status: 'rejected')
                subject.submit
              end

              it 'will update the additional attributes' do
                ['project_proposal_decision'].each do |attribute_name|
                  expect(repository).to receive(:update_work_attribute_values!).with(
                    work: work, key: attribute_name, values: attributes.fetch(attribute_name.to_sym)
                  ).and_call_original
                end
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
