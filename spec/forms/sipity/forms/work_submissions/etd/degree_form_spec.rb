require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/degree_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe DegreeForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:degree) { 'degree_name' }
          let(:program) { 'program_name' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { is_expected.to eq('degree') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :degree }
          it { is_expected.to respond_to :program_name }

          it 'will require a degree' do
            subject.valid?
            expect(subject.errors[:degree]).to be_present
            expect(subject.errors[:program_name]).to be_present
          end

          it 'will require a program_name' do
            subject.valid?
            expect(subject.errors[:program_name]).to be_present
          end

          it 'will only keep degree entries that are "present?"' do
            subject = described_class.new(keywords.merge(attributes: { degree: ['hello', '', nil, 'world'] }))
            expect(subject.degree).to eq(['hello', 'world'])
          end

          it 'will only keep program_names entries that are "present?"' do
            subject = described_class.new(keywords.merge(attributes: { program_name: ['hello', '', nil, 'world'] }))
            expect(subject.program_name).to eq(['hello', 'world'])
          end

          it 'will have #available_degrees' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'degree').
              and_return(['degree_name', 'bogus'])
            expect(subject.available_degrees).to be_a(Array)
          end

          it 'will have #available_program_names' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'program_name').
              and_return(['bogus'])
            expect(subject.available_program_names).to eq(['bogus'])
          end

          context '#degree' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { degree: ['bogus', 'test'] }))
              expect(subject.degree).to eq ['bogus', 'test']
            end
            it 'will fall back on #degree information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'degree', cardinality: 1).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.degree).to eq(['hello'])
            end
          end

          context '#program_name' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { program_name: ['bogus', 'test'] }))
              expect(subject.program_name).to eq ['bogus', 'test']
            end
            it 'will fall back on #program_name information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'program_name').and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.program_name).to eq(['hello'])
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
                described_class.new(keywords.merge(attributes: { degree: 'bogus', program_name: 'fake name' }))
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
