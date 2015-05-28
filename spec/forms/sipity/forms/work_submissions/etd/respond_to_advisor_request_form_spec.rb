require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RespondToAdvisorRequestForm do
          let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
          let(:work) { double('Work', to_processing_entity: processing_entity) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:action) do
            Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: 'respond_to_advisor_request')
          end
          let(:user) { User.new(id: 1) }
          subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

          context '#render' do
            let(:f) { double }
            it 'will return an input text area' do
              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              subject.render(f: f)
            end
          end

          its(:input_legend) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'with valid data' do
            let(:a_processing_comment) { double }
            let(:an_action) { double(resulting_strategy_state: double) }
            before do
              allow(subject).to receive(:convert_to_processing_action).and_return(an_action)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              allow(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
            end

            it 'will send creating user a note that the advisor has requested changes' do
              expect(repository).to receive(:deliver_notification_for).
                with(the_thing: a_processing_comment, scope: an_action, requested_by: user).
                and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the processing comment' do
              expect(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
