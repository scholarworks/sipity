require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe SubmitForIngestForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(repository).to receive(:authorized_for_processing?).and_return(false)
                expect(Sipity::Exporters::EtdExporter).to_not receive(:call).with(work)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(keywords)
              end

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                expect(Sipity::Exporters::EtdExporter).to receive(:call).with(work)
              end

              it 'will submit successfully if valid' do
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
