require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module SelfDeposit
        RSpec.describe AffiliationForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:affiliation) { 'affiliation_name' }
          let(:organization) { 'organization' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('affiliation') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          it { should respond_to :affiliation }
          it { should respond_to :organization }

          it 'will require a affiliation' do
            subject.valid?
            expect(subject.errors[:affiliation]).to be_present
            expect(subject.errors[:organization]).to be_present
          end

          it 'will require a organization' do
            subject.valid?
            expect(subject.errors[:organization]).to be_present
          end

          it 'will only keep affiliation entries that are "present?"' do
            subject = described_class.new(keywords.merge(attributes: { affiliation: ['hello', '', nil, 'world'] }))
            expect(subject.affiliation).to eq(['hello', 'world'])
          end

          it 'will only keep organizations entries that are "present?"' do
            subject = described_class.new(keywords.merge(attributes: { organization: ['hello', '', nil, 'world'] }))
            expect(subject.organization).to eq(['hello', 'world'])
          end

          it 'will have #available_affiliations' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'affiliation').
              and_return(['affiliation_name', 'bogus'])
            expect(subject.available_affiliations).to be_a(Array)
          end

          it 'will have #available_organizations' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'organization').
              and_return(['bogus'])
            expect(subject.available_organizations).to eq(['bogus'])
          end

          context '#affiliation' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { affiliation: ['bogus', 'test'] }))
              expect(subject.affiliation).to eq ['bogus', 'test']
            end
            it 'will fall back on #affiliation information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'affiliation').and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.affiliation).to eq(['hello'])
            end
          end

          context '#organization' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { organization: ['bogus', 'test'] }))
              expect(subject.organization).to eq ['bogus', 'test']
            end
            it 'will fall back on #organization information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'organization').and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.organization).to eq(['hello'])
            end
          end

          context '#submit' do
            let(:user) { double('User') }
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
                described_class.new(keywords.merge(attributes: { affiliation: 'bogus', organization: 'fake name' }))
              end

              before do
                allow(subject).to receive(:valid?).and_return(true)
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
