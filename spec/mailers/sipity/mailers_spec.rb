require "rails_helper"
require 'sipity/mailers'

module Sipity
  RSpec.describe Mailers do
    before do
      module Mailers
        module MockMailer
          def self.my_notification
          end
        end
      end
    end
    after { described_class.send(:remove_const, :MockMailer) }
    let(:entity) { Models::WorkArea.new(id: '1', slug: 'mock', demodulized_class_prefix_name: 'mock') }
    let(:notification) { :my_notification }
    context '.find_mailer_for' do
      it 'will find correct mailer class based on the work area' do
        expect(described_class.find_mailer_for(entity: entity, notification: notification)).to eq(described_class::MockMailer)
      end
      it 'will convert the entity to a work area' do
        expect(PowerConverter).to receive(:convert).with(entity, to: :work_area).and_call_original
        described_class.find_mailer_for(entity: entity, notification: notification)
      end
      it 'will raise an exception if the notification is undefined for the mailer' do
        expect do
          described_class.find_mailer_for(entity: entity, notification: "another_#{notification}")
        end.to raise_error(Exceptions::NotificationNotFoundError)
      end
    end
  end
end
