require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/grad_school_signoff_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe GradSchoolSignoffForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true })) }

          context 'validation' do
            it 'will require agreement to the signoff' do
              subject = described_class.new(keywords)
              subject.valid?
              expect(subject.errors[:agree_to_signoff]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { is_expected.to be_html_safe }
          its(:signoff_agreement) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }
        end
      end
    end
  end
end
