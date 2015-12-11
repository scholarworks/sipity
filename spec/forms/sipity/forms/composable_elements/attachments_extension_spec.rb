require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/composable_elements/attachments_extension'

module Sipity
  module Forms
    module ComposableElements
      RSpec.describe AttachmentsExtension do

        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        let(:user) { double('User') }
        let(:attachments_attributes) do
          {
            "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
            "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
            "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
          }
        end
        let(:errors) { double(add: true) }
        let(:form) { double('Form', work: work, errors: errors) }
        let(:predicate_name) { 'chicken' }
        subject do
          described_class.new(
            repository: repository, form: form, files: {}, attachments_attributes: attachments_attributes, predicate_name: predicate_name
          )
        end

        its(:default_predicate_name) { should eq('attachment') }

        it { should respond_to :repository }
        it { should respond_to :files }
        it { should respond_to :attach_or_update_files }
        it { should respond_to :attachments_attributes= }
        it { should respond_to :attachments }
        it { should delegate_method(:errors).to(:form) }

        its(:default_predicate_name) { should eq('attachment') }

        context '#at_least_one_file_must_be_attached' do
          it 'will return true if there are works assigned' do
            expect(subject).to receive(:attachments_associated_with_the_work?).and_return(true)
            expect(subject.send(:at_least_one_file_must_be_attached)).to eq(true)
          end

          it 'will add errors to the object' do
            expect(subject).to receive(:attachments_associated_with_the_work?).and_return(false)
            expect(errors).to receive(:add).with(:base, :at_least_one_attachment_required)
            subject.send(:at_least_one_file_must_be_attached)
          end
        end

        it 'will call attachments_from_work' do
          expect(repository).to receive(:work_attachments).with(work: work, predicate_name: predicate_name).and_return([double, double])
          subject.attachments
        end

        it 'will wrap the files in an array' do
          described_class.new(repository: repository, form: form, files: double, attachments_attributes: attachments_attributes)
          expect(subject.files).to be_a(Array)
        end

        context 'attach_or_update_files' do
          let(:attachments_attributes) do
            {
              "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
              "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
              "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" },
              "3" => { "name" => "conference.pdf", "delete" => "0", "id" => "77Z8v5yGshHFgE6fS4FRew==" }
            }
          end

          it 'will update attachments' do
            subject.attachments_attributes = attachments_attributes
            expect(repository).to receive(:amend_files_metadata).
              with(
                work: work, user: user, metadata: {
                  "y5Fm8YK9-ekjEwUMKeeutw==" => { "name" => "hotel.pdf" },
                  "64Y9v5yGshHFgE6fS4FRew==" => { "name" => "code4lib.pdf" },
                  "77Z8v5yGshHFgE6fS4FRew==" => { "name" => "conference.pdf" }
                }
              )
            subject.attach_or_update_files(requested_by: user)
          end
        end
      end
    end
  end
end
