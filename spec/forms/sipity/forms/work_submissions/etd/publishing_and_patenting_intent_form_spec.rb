require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/publishing_and_patenting_intent_form'
require 'sipity/models/work'
require 'sipity/policies/work_policy'
require 'sipity/models/work_area'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe PublishingAndPatentingIntentForm do
          let(:keywords) { { repository: repository, work: work, attributes: attributes, requested_by: user } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:work) { Models::Work.new(id: 1) }
          let(:work_area) { Models::WorkArea.new(id: 2, slug: 'etd') }
          let(:user) { double }
          before { allow(work).to receive(:work_area).and_return(work_area) }

          it { is_expected.to implement_processing_form_interface }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }
          its(:base_class) { is_expected.to eq Models::Work }

          it { is_expected.to delegate_method(:work_patent_strategy).to(:publication_and_patenting_intent_extension) }
          it { is_expected.to delegate_method(:work_patent_strategies_for_select).to(:publication_and_patenting_intent_extension) }
          it { is_expected.to delegate_method(:work_publication_strategy).to(:publication_and_patenting_intent_extension) }
          it { is_expected.to delegate_method(:work_publication_strategies_for_select).to(:publication_and_patenting_intent_extension) }

          context 'validation' do
            before do
              allow_any_instance_of(described_class).to receive(:possible_work_publication_strategies).and_return(['valid'])
              allow_any_instance_of(described_class).to receive(:possible_work_patent_strategies).and_return(['valid'])
            end
            context '#work_publication_strategy' do
              it 'will be invalid if it is not present' do
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: nil }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to be_present
              end
              it 'will be invalid if not in the list of available options' do
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: '__invalid__' }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to be_present
              end
              it 'will be valid if from the list of available options' do
                subject = described_class.new(keywords.merge(attributes: { work_publication_strategy: 'valid' }))
                subject.valid?
                expect(subject.errors[:work_publication_strategy]).to_not be_present
              end
            end

            context '#work_patent_strategy' do
              it 'will be invalid if it is not present' do
                subject = described_class.new(keywords.merge(attributes: { work_patent_strategy: nil }))
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to be_present
              end
              it 'will be invalid if not in the list of available options' do
                subject = described_class.new(keywords.merge(attributes: { work_patent_strategy: '__invalid__' }))
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to be_present
              end
              it 'will be valid if from the list of available options' do
                subject = described_class.new(keywords.merge(attributes: { work_patent_strategy: 'valid' }))
                subject.valid?
                expect(subject.errors[:work_patent_strategy]).to_not be_present
              end
            end
          end

          context 'submit an invalid form' do
            before { allow(subject).to receive(:valid?).and_return(false) }
            it 'will return false' do
              expect(subject.submit).to eq(false)
            end
            it 'will not yield control to the form' do
              expect(subject.send(:processing_action_form)).to receive(:submit)
              subject.submit
            end
          end

          context 'submit a valid form' do
            before { allow(subject.send(:processing_action_form)).to receive(:submit).and_yield }
            it 'will persist_work_publication_strategy' do
              expect(subject).to receive(:persist_work_publication_strategy)
              subject.submit
            end
            it 'will persist_work_patent_strategy' do
              expect(subject).to receive(:persist_work_patent_strategy)
              subject.submit
            end
          end
        end
      end
    end
  end
end
