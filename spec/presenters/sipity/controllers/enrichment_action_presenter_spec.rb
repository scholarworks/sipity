require 'spec_helper'
require 'sipity/controllers/enrichment_action_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/enrichment_action_presenter'

module Sipity
  module Controllers
    RSpec.describe EnrichmentActionPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:enrichment_action) { double(name: 'create_a_window', id: 1) }
      let(:entity) { Models::Work.new(id: '12ab') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:enrichment_action_set) do
        Parameters::ActionSetParameter.new(identifier: 'required', collection: [enrichment_action], entity: entity)
      end
      subject do
        described_class.new(
          context,
          enrichment_action: enrichment_action,
          enrichment_action_set: enrichment_action_set,
          repository: repository
        )
      end

      its(:default_repository) { is_expected.to respond_to(:scope_statetegy_actions_that_have_occurred) }
      its(:default_repository) { is_expected.to respond_to(:scope_strategy_actions_that_are_prerequisites) }

      its(:identifier) { is_expected.to eq(enrichment_action_set.identifier) }
      its(:entity) { is_expected.to eq(enrichment_action_set.entity) }
      its(:action_name) { is_expected.to eq(enrichment_action.name) }
      its(:path) { is_expected.to be_a(String) }

      it 'will delegate #label to the TranslationAssistant' do
        expect(TranslationAssistant).to receive(:call)
        subject.label
      end

      it { is_expected.to respond_to(:complete?) }
      it { is_expected.to respond_to(:a_prerequisite?) }

      it 'will be a prerequisite if the associated action is a prerequisite' do
        allow(repository).to receive(:scope_strategy_actions_that_are_prerequisites).
          with(entity: entity, pluck: :id).and_return([enrichment_action.id])
        expect(subject.a_prerequisite?).to be_truthy
      end

      context 'when complete' do
        before do
          allow(repository).to receive(:scope_statetegy_actions_that_have_occurred).
            with(entity: entity, pluck: :id).and_return([enrichment_action.id])
          allow(repository).to receive(:scope_strategy_actions_that_are_prerequisites).
            with(entity: entity, pluck: :id).and_return([enrichment_action.id])
        end

        its(:completion_mark_if_applicable) { is_expected.to be_present }
        its(:completion_mark_if_applicable) { is_expected.to be_html_safe }
        its(:todo_checkbox_element) { is_expected.to be_html_safe }
        its(:todo_checkbox_element) { is_expected.to have_tag('span.circle.done') }
        its(:todo_checkbox_element) { is_expected.to have_tag('svg') }
        its(:state) { is_expected.to eq('done') }
        its(:complete?) { is_expected.to be_truthy }
      end

      context 'when incomplete' do
        before do
          allow(repository).to receive(:scope_statetegy_actions_that_have_occurred).with(entity: entity, pluck: :id).and_return([])
          allow(repository).to receive(:scope_strategy_actions_that_are_prerequisites).
            with(entity: entity, pluck: :id).and_return([enrichment_action.id])
        end

        its(:completion_mark_if_applicable) { is_expected.not_to be_present }
        its(:completion_mark_if_applicable) { is_expected.to be_html_safe }
        its(:todo_checkbox_element) { is_expected.to be_html_safe }
        its(:todo_checkbox_element) { is_expected.to have_tag('span.circle.incomplete') }
        its(:todo_checkbox_element) { is_expected.not_to have_tag('svg') }
        its(:state) { is_expected.to eq('incomplete') }
        its(:complete?) { is_expected.to be_falsey }
      end

      context '#button_class' do
        [
          { complete?: true, a_prerequisite?: true, expected_button_class: 'btn-default' },
          { complete?: true, a_prerequisite?: false, expected_button_class: 'btn-default' },
          { complete?: false, a_prerequisite?: true, expected_button_class: 'btn-primary' },
          { complete?: false, a_prerequisite?: false, expected_button_class: 'btn-info' }
        ].each do |scenario|
          it "will have button_class='#{scenario.fetch(:expected_button_class)}' for
            complete?:#{scenario.fetch(:complete?).inspect} and a_prerequisite?:#{scenario.fetch(:a_prerequisite?).inspect}" do
            allow(subject).to receive(:complete?).and_return(scenario.fetch(:complete?))
            allow(subject).to receive(:a_prerequisite?).and_return(scenario.fetch(:a_prerequisite?))
            expect(subject.button_class).to eq(scenario.fetch(:expected_button_class))
          end
        end
      end
    end
  end
end
