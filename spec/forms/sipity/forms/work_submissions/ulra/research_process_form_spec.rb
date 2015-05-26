require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe ResearchProcessForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:citation_style) { 'other' }
          let(:resource_consulted) { ['dummy', 'test'] }
          let(:other_resource_consulted) { 'some other value' }
          subject { described_class.new(work: work, repository: repository) }

          its(:enrichment_type) { should eq('research_process') }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            it { should delegate_method(:model_name).to(:base_class) }
            it { should delegate_method(:human_attribute_name).to(:base_class) }
          end

          it { should respond_to :work }
          it { should respond_to :resource_consulted }
          it { should respond_to :other_resource_consulted }
          it { should respond_to :citation_style }
          it { should respond_to :attachments }
          it { should respond_to :files }
          it { should_not be_persisted }

          it 'will require a citation_style' do
            subject.valid?
            expect(subject.errors[:citation_style]).to be_present
          end

          it 'will require a non-blank citation_stype' do
            subject = described_class.new(work: work, repository: repository, attributes: { citation_style: '' })
            subject.valid?
            expect(subject.errors[:citation_style]).to be_present
          end

          it 'will require a non-blank citation_style' do
            subject = described_class.new(work: work, repository: repository, attributes: { citation_style: 'chocolate' })
            subject.valid?
            expect(subject.errors[:citation_style]).to_not be_present
          end

          it 'will have #available_resouce_consulted' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'resource_consulted').
              and_return(['some value', 'bogus'])
            expect(subject.available_resource_consulted).to be_a(Array)
          end

          it 'will have #available_citation_style' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'citation_style').
              and_return(['test', 'bogus', 'more bogus'])
            expect(subject.available_citation_style).to be_a(Array)
          end

          it 'will call attachments_from_work' do
            expect(repository).to receive(:work_attachments).with(work: work).and_return([double, double])
            subject.attachments
          end

          context 'assigning attachments attributes' do
            let(:user) { double('User') }
            let(:attachments_attributes) do
              {
                "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
              }
            end
            subject do
              described_class.new(work: work, repository: repository, attributes: { attachments_attributes: attachments_attributes })
            end

            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              allow(subject).to receive(:valid?).and_return(true)
            end

            it 'will delete any attachments marked for deletion' do
              expect(repository).to receive(:remove_files_from).with(work: work, user: user, pids: ["i8tnddObffbIfNgylX7zSA=="])
              subject.submit(requested_by: user)
            end

            it 'will amend any attachment metadata' do
              expect(repository).to receive(:amend_files_metadata).with(
                work: work, user: user, metadata: {
                  "y5Fm8YK9-ekjEwUMKeeutw==" => { "name" => "hotel.pdf" },
                  "64Y9v5yGshHFgE6fS4FRew==" => { "name" => "code4lib.pdf" }
                }
              )
              subject.submit(requested_by: user)
            end
          end

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:resource_consulted) { ['dummy', 'test'] }
              let(:other_resource_consulted) { 'some other value' }
              let(:citation_style) { 'other' }
              subject { described_class.new(work: work, repository: repository, attributes: {}) }
              it 'will return the resource_consulted of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'resource_consulted').and_return(resource_consulted)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'other_resource_consulted').and_return(other_resource_consulted)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'citation_style').and_return(citation_style)
                expect(subject.resource_consulted).to eq resource_consulted
                expect(subject.other_resource_consulted).to eq other_resource_consulted
                expect(subject.citation_style).to eq citation_style
              end
            end
          end
          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit(requested_by: user))
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(
                  work: work, repository: repository, attributes: {
                    resource_consulted: resource_consulted,
                    other_resource_consulted: other_resource_consulted,
                    citation_style: citation_style
                  }
                )
              end
              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(3).and_call_original
                subject.submit(requested_by: user)
              end
            end
          end
        end
      end
    end
  end
end
