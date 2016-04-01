require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/attach_form'

module Sipity
  module ProcessingHooks
    module Ulra
      module Works
        RSpec.describe AttachProcessingHook do
          context '.call' do
            let(:repository) { CommandRepositoryInterface.new }
            let(:strategy_state) { Models::Processing::StrategyState.new }
            let(:entity) { Models::Processing::Entity.new(strategy_state: strategy_state) }
            let(:action) { double('Action') }
            let(:user) { double('User') }

            subject { described_class }

            its(:default_repository) { is_expected.to respond_to(:deliver_notification_for) }

            it 'will deliver notifications if the attachment entry is complete' do
              expect(repository).
                to receive(:deliver_notification_for).with(
                  scope: strategy_state, the_thing: entity, repository: repository, requested_by: user, reason: 'processing_hook_triggered'
                ).and_call_original
              expect(repository).to receive(:work_attribute_values_for).
                with(work: entity, key: 'attached_files_completion_state', cardinality: 1).
                and_return(Forms::WorkSubmissions::Ulra::AttachForm::COMPLETE_STATE)

              subject.call(entity: entity, action: action, requested_by: user, repository: repository)
            end

            it 'will not deliver notifications if the attachment entry is incomplete' do
              expect(repository).to_not receive(:deliver_notification_for)
              expect(repository).to receive(:work_attribute_values_for).
                with(work: entity, key: 'attached_files_completion_state', cardinality: 1).
                and_return('incomplete')

              subject.call(entity: entity, action: action, requested_by: user, repository: repository)
            end
          end
        end
      end
    end
  end
end
