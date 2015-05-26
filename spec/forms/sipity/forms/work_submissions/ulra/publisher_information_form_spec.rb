require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe PublisherInformationForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:publication_name) { 'publication_name' }
          let(:allow_pre_prints) { 'Yes' }
          let(:repository) { CommandRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:enrichment_type) { should eq('publisher_information') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            it { should delegate_method(:model_name).to(:base_class) }
            it { should delegate_method(:human_attribute_name).to(:base_class) }
          end

          it { should respond_to :work }
          it { should respond_to :entity }
          it { should respond_to :publication_name }
          it { should respond_to :allow_pre_prints }
          it { should_not be_persisted }

          it 'will require a publication' do
            subject.valid?
            expect(subject.errors[:publication_name]).to be_present
            expect(subject.errors[:allow_pre_prints]).to be_present
          end

          it 'will require a allow_pre_prints' do
            subject.valid?
            expect(subject.errors[:allow_pre_prints]).to be_present
          end

          it 'with valid allow_pre_prints' do
            form_obj = described_class.new(
              work: work, repository: repository, attributes: { publication_name: "dummy", allow_pre_prints: "Yes" }
            )
            form_obj.valid?
            expect(form_obj.errors[:allow_pre_prints]).not_to be_present
          end

          it 'with invalid allow_pre_prints' do
            form_obj = described_class.new(
              work: work, repository: repository, attributes: { publication_name: "dummy", allow_pre_prints: "dummy" }
            )
            form_obj.valid?
            expect(form_obj.errors[:allow_pre_prints]).to be_present
          end

          it 'will require at least one non-blank allow_pre_prints' do
            subject = described_class.new(
              work: work, repository: repository, attributes: { publication_name: "dummy", allow_pre_prints: ["", ""] }
            )
            subject.valid?
            expect(subject.errors[:allow_pre_prints]).to be_present
          end

          it 'will require at least one non-blank allow_pre_prints' do
            subject = described_class.new(
              work: work, repository: repository, attributes: { publication_name: "dummy", allow_pre_prints: ["I do not know", ""] }
            )
            subject.valid?
            expect(subject.errors[:allow_pre_prints]).to_not be_present
          end

          it 'will only keep publication entries that are "present?"' do
            subject = described_class.new(work: work, repository: repository, attributes: { publication_name: publication_name })
            expect(subject.publication_name).to eq(publication_name)
          end

          it 'will only keep allow_pre_printss entries that are "present?"' do
            subject = described_class.new(work: work, repository: repository, attributes: { allow_pre_prints: ['Yes'] })
            expect(subject.allow_pre_prints).to eq(['Yes'])
          end

          context '#publication_name' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, repository: repository, attributes: { publication_name: 'test' })
              expect(subject.publication_name).to eq 'test'
            end
            it 'will fall back on #publication information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'publication_name').and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.publication_name).to eq('hello')
            end
          end

          context '#allow_pre_prints' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, repository: repository, attributes: { allow_pre_prints: ['Yes'] })
              expect(subject.allow_pre_prints).to eq ['Yes']
            end
            it 'will fall back on #allow_pre_prints information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'allow_pre_prints').and_return('Yes')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.allow_pre_prints).to eq(['Yes'])
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
                described_class.new(work: work, repository: repository, attributes: { publication_name: 'bogus', allow_pre_prints: 'No' })
              end
              before do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                allow(subject).to receive(:valid?).and_return(true)
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(2).and_call_original
                subject.submit(requested_by: user)
              end
            end
          end
        end
      end
    end
  end
end
