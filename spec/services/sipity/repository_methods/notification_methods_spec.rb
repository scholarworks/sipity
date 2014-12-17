require 'spec_helper'

module Sipity
  module RepositoryMethods
    RSpec.describe NotificationMethods, type: :repository_methods do
      context '#send_notification_for_entity_trigger' do
        let(:notification) { double }
        let(:entity) { double }
        let(:to_roles) { double }

        it 'is a placeholder' do
          test_repository.send_notification_for_entity_trigger(notification: notification, entity: entity, to_roles: to_roles)
        end
      end
    end
  end
end
