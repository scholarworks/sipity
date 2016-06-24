require "rails_helper"
require 'sipity/parameters/notification_context_parameter'

module Sipity
  module DataGenerators
    RSpec.describe EmailNotificationGenerator do
      let(:strategy) { Models::Processing::Strategy.new(id: 1) }
      let(:scope) { 'show' }
      let(:email_name) { :the_weasel }
      let(:recipients) { { to: 'creating_user', cc: 'advising', bcc: "data_observing" } }

      context '#call' do
        context 'with for reason: REASON_ACTION_IS_TAKEN' do
          let(:reason) { Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN }
          it 'will generate the requisite entries' do
            strategy_action = Sipity::Models::Processing::StrategyAction.create!(strategy_id: strategy.id, name: scope)
            expect do
              expect do
                expect do
                  described_class.call(strategy: strategy, reason: reason, scope: scope, email_name: email_name, recipients: recipients)
                end.to change { Models::Notification::Email.count }.by(1)
              end.to change { Models::Notification::EmailRecipient.count }.by(3)
            end.to change { strategy_action.notifiable_contexts.count }.by(1)
          end
        end

        context 'with for reason: REASON_ENTERED_STATE' do
          let(:reason) { Parameters::NotificationContextParameter::REASON_ENTERED_STATE }
          it 'will generate the requisite entries' do
            strategy_state = Sipity::Models::Processing::StrategyState.create!(strategy_id: strategy.id, name: scope)
            expect do
              expect do
                expect do
                  described_class.call(strategy: strategy, reason: reason, scope: scope, email_name: email_name, recipients: recipients)
                end.to change { Models::Notification::Email.count }.by(1)
              end.to change { Models::Notification::EmailRecipient.count }.by(3)
            end.to change { strategy_state.notifiable_contexts.count }.by(1)
          end
        end

        context 'with for reason: REASON_PROCESSING_HOOK_TRIGGERED' do
          let(:reason) { Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED }
          it 'will generate the requisite entries' do
            strategy_state = Sipity::Models::Processing::StrategyState.create!(strategy_id: strategy.id, name: scope)
            expect do
              expect do
                expect do
                  described_class.call(strategy: strategy, reason: reason, scope: scope, email_name: email_name, recipients: recipients)
                end.to change { Models::Notification::Email.count }.by(1)
              end.to change { Models::Notification::EmailRecipient.count }.by(3)
            end.to change { strategy_state.notifiable_contexts.count }.by(1)
          end
        end
      end
    end
  end
end
