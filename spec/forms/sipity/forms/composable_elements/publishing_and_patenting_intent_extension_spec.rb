require 'spec_helper'
require 'support/sipity/command_repository_interface'

module Sipity
  module Forms
    module ComposableElements
      RSpec.describe PublishingAndPatentingIntentExtension do
        let(:form) { double(work: double('Work')) }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(form: form, repository: repository) }

        its(:default_repository) { is_expected.to respond_to :update_work_attribute_values! }
        its(:default_repository) { is_expected.to respond_to :get_controlled_vocabulary_values_for_predicate_name }

        it 'guards that the form has a work' do
          expect { described_class.new(form: double, repository: repository) }.to raise_error(Exceptions::InterfaceExpectationError)
        end

        context '#work_publication_strategy' do
          before do
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).
              with(name: subject.send(:work_publication_strategy_predicate_name)).and_return(['hello', 'world'])
          end

          it { is_expected.to respond_to :work_publication_strategy }

          it 'will have #work_publication_strategies_for_select that are all symbols' do
            expect(subject.work_publication_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
          end

          it 'will have #possible_work_publication_strategies that is a hash' do
            # SimpleForm accepts a Hash
            expect(subject.possible_work_publication_strategies).to eq(['hello', 'world'])
          end

          it 'will #persist_work_publication_strategy' do
            subject.work_publication_strategy = double
            expect(repository).to receive(:update_work_attribute_values!).
              with(work: form.work, key: subject.send(:work_publication_strategy_predicate_name), values: subject.work_publication_strategy)
            subject.persist_work_publication_strategy
          end
        end

        context '#work_patent_strategy' do
          before do
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).
              with(name: subject.send(:work_patent_strategy_predicate_name)).and_return(['hello', 'world'])
          end

          it { is_expected.to respond_to :work_patent_strategy }

          it 'will have #work_patent_strategies_for_select that are all symbols' do
            expect(subject.work_patent_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
          end

          it 'will have #possible_work_patent_strategies that is a hash' do
            expect(subject.possible_work_patent_strategies).to eq(['hello', 'world'])
          end

          it 'will #persist_work_patent_strategy' do
            subject.work_patent_strategy = double
            expect(repository).to receive(:update_work_attribute_values!).
              with(work: form.work, key: subject.send(:work_patent_strategy_predicate_name), values: subject.work_patent_strategy)
            subject.persist_work_patent_strategy
          end
        end
      end
    end
  end
end
