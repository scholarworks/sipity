require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe NotificationQueries, type: :isolated_repository_module do

      context '#email_notifications_for' do
        let(:reason_for_notification) { 'action_is_taken' }
        let(:scope_for_notification) { Models::Processing::StrategyAction.new(id: 1) }
        let(:separate_scope_for_notification) { Models::Processing::StrategyAction.new(id: 2) }
        let!(:email_not_to_send) { Models::Notification::Email.create!(method_name: 'not_to_send') }
        let!(:email_to_send) { Models::Notification::Email.create!(method_name: 'to_send') }
        before do
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: scope_for_notification.id,
            scope_for_notification_type: Conversions::ConvertToPolymorphicType.call(scope_for_notification),
            reason_for_notification: reason_for_notification,
            email: email_to_send
          )
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: scope_for_notification.id,
            scope_for_notification_type: Conversions::ConvertToPolymorphicType.call(scope_for_notification),
            reason_for_notification: "some_other_#{reason_for_notification}",
            email: email_not_to_send
          )
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: separate_scope_for_notification.id,
            scope_for_notification_type: Conversions::ConvertToPolymorphicType.call(separate_scope_for_notification),
            reason_for_notification: "some_other_#{reason_for_notification}",
            email: email_not_to_send
          )
        end

        it 'will return the email objects' do
          expect(test_repository.email_notifications_for(context: reason_for_notification, concerning: scope_for_notification)).
            to eq([email_to_send])
        end
      end
    end
  end
end
