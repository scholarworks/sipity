require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe SearchTermForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        its(:enrichment_type) { should eq('search_term') }
        its(:policy_enforcer) { should eq Policies::Processing::ProcessingEntityPolicy }

        it { should respond_to :work }
        it { should respond_to :subject }
        it { should respond_to :language }
        it { should respond_to :temporal_coverage }
        it { should respond_to :spatial_coverage }

        context 'without specified values' do
          before do
            allow(repository).to receive(:work_attribute_values_for)
          end
          ['subject', 'language', 'temporal_coverage', 'spatial_coverage'].each do |key|
            it "will retrieve the #{key} from the repository" do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: key.to_s).and_return("#{key}_value")
              expect(subject.send(key)).to eq("#{key}_value")
            end
          end
        end

        context '#submit' do
          let(:user) { double('User') }
          let(:subject_attr) { 'Literature' }
          let(:language) { 'English' }
          let(:temporal_coverage) { '1999 - 2014' }
          let(:spatial_coverage) { '20 sq miles' }
          context 'with valid data' do
            subject do
              described_class.new(
                work: work, subject: subject_attr, language: language,
                temporal_coverage: temporal_coverage, spatial_coverage: spatial_coverage,
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
              expect(repository).to receive(:update_work_attribute_values!).exactly(4).and_call_original
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
