require "rails_helper"
require 'sipity/mailer_builder'

module Sipity
  RSpec.describe MailerBuilder do
    context '.build' do
      subject { described_class.build('wookie') { email(name: 'chewbacca', as: :work) } }
      its(:superclass) { is_expected.to eq(ActionMailer::Base) }
      its(:mailer_name) { is_expected.to eq('sipity/mailers/wookie_mailer') }
      its(:emails) { is_expected.to be_a(Array) }
      its(:instance_methods) { is_expected.to include(:chewbacca) }

      it 'will not build if given the wrong as: option for email configuration' do
        expect do
          described_class.build('wookie') { email(name: 'chewbacca', as: :monster) }
        end.to raise_error(Exceptions::EmailAsOptionInvalidError)
      end
    end
  end
end
