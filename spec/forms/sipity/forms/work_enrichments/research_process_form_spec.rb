require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe ResearchProcessForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        let(:citation_style) { 'other' }
        let(:resource_consulted) { ['dummy', 'test'] }
        let(:other_resource_consulted) { 'some other value' }
        subject { described_class.new(work: work, repository: repository) }

        its(:enrichment_type) { should eq('research_process') }

        it { should respond_to :work }
        it { should respond_to :resource_consulted }
        it { should respond_to :other_resource_consulted }
        it { should respond_to :citation_style }

        it 'will require a citation_style' do
          subject.valid?
          expect(subject.errors[:citation_style]).to be_present
        end

        it 'will require a non-blank citation_stype' do
          subject = described_class.new(work: work, repository: repository, citation_style: '')
          subject.valid?
          expect(subject.errors[:citation_style]).to be_present
        end

        it 'will require a non-blank citation_style' do
          subject = described_class.new(work: work, repository: repository, citation_style: 'chocolate')
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

        context 'retrieving values from the repository' do
          context 'with data from the database' do
            let(:resource_consulted) { ['dummy', 'test'] }
            let(:other_resource_consulted) { 'some other value' }
            let(:citation_style) { 'other' }
            subject { described_class.new(work: work, repository: repository) }
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
                work: work,
                resource_consulted: resource_consulted,
                other_resource_consulted: other_resource_consulted,
                citation_style: citation_style,
                repository: repository
              )
            end
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will return the work' do
              returned_value = subject.submit(requested_by: user)
              expect(returned_value).to eq(work)
            end

            it "will transition the work's corresponding enrichment todo item to :done" do
              expect(repository).to receive(:register_action_taken_on_entity).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).exactly(3).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the event' do
              expect(repository).to receive(:log_event!).and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
