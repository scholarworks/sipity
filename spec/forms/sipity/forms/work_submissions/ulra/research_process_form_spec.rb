require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/research_process_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe ResearchProcessForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, requested_by: user, repository: repository } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('research_process') }
          its(:attachment_predicate_name) { should eq('submission_essay') }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            it { should delegate_method(:model_name).to(:base_class) }
            it { should delegate_method(:human_attribute_name).to(:base_class) }
          end

          it { should respond_to :work }
          it { should respond_to :resources_consulted }
          it { should respond_to :other_resources_consulted }
          it { should respond_to :attachments }
          it { should respond_to :files }
          it { is_expected.not_to be_persisted }

          it { should delegate_method(:at_least_one_file_must_be_attached).to(:attachments_extension) }
          it { should delegate_method(:attachments).to(:attachments_extension) }

          include Shoulda::Matchers::ActiveModel

          context '#top_level_categories' do
            it 'will be friendly for rendering HTML input fields' do
              expect(subject).to receive(:available_resources_consulted).and_return(["Hello::World", "Nice::Day", "Hello::Hamster"])
              expect(subject.top_level_categories).to eq(
                "Hello" => [["World", "Hello::World"], ["Hamster", "Hello::Hamster"]],
                "Nice" => [["Day", "Nice::Day"]]
              )
            end
          end

          it 'will have #available_resouce_consulted' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).
              with(name: described_class::RESOURCES_CONSULTED_CONTROLLED_VOCABULARY_KEY).
              and_return(['some value', 'bogus'])
            expect(subject.available_resources_consulted).to be_a(Array)
          end

          it 'will validate at_least_one_file_must_be_attached' do
            expect(subject.send(:attachments_extension)).to receive(:at_least_one_file_must_be_attached)
            subject.valid?
          end

          context 'assigning attachments attributes' do
            let(:attachments_attributes) do
              {
                "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
              }
            end
            subject do
              described_class.new(keywords.merge(attributes: { attachments_attributes: attachments_attributes }))
            end

            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              allow(subject).to receive(:valid?).and_return(true)
            end

            it 'will delete any attachments marked for deletion' do
              expect(subject.send(:attachments_extension)).to receive(:attach_or_update_files).with(
                requested_by: subject.send(:requested_by)
              )
              subject.submit
            end
          end

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:resources_consulted) { ['dummy', 'test'] }
              let(:other_resources_consulted) { 'some other value' }
              subject { described_class.new(keywords) }
              it 'will return the resources_consulted of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'resources_consulted').and_return(resources_consulted)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'other_resources_consulted').and_return(other_resources_consulted)
                expect(subject.resources_consulted).to eq resources_consulted
                expect(subject.other_resources_consulted).to eq other_resources_consulted
              end
            end
          end
          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(
                  keywords.merge(
                    attributes: { resources_consulted: 'a resource', other_resources_consulted: 'another' }
                  )
                )
              end
              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(2).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
