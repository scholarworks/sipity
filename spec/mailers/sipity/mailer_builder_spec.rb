require 'spec_helper'
require 'sipity/mailer_builder'

module Sipity
  RSpec.describe MailerBuilder do
    context '.build' do
      subject { described_class.build('wookie') { email(name: 'chewbacca', as: :work) } }
      its(:superclass) { should eq(ActionMailer::Base) }
      its(:mailer_name) { should eq('sipity/mailers/wookie_mailer') }
      its(:emails) { should be_a(Array) }
      its(:instance_methods) { should include(:chewbacca) }

      it 'will not build if given the wrong as: option for email configuration' do
        expect do
          described_class.build('wookie') { email(name: 'chewbacca', as: :monster) }
        end.to raise_error(Exceptions::EmailAsOptionInvalidError)
      end
    end
  end
end
