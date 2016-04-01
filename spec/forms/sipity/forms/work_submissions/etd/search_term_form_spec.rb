require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/search_term_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe SearchTermForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, repository: repository, requested_by: double('User') } }
          subject { described_class.new(keywords) }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :subject }
          it { is_expected.to respond_to :language }
          it { is_expected.to respond_to :temporal_coverage }
          it { is_expected.to respond_to :spatial_coverage }

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
                  keywords.merge(
                    attributes: {
                      subject: subject_attr, language: language, temporal_coverage: temporal_coverage, spatial_coverage: spatial_coverage
                    }
                  )
                )
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(4).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
