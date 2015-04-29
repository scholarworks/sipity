require 'rails_helper'

module Sipity
  module DataGenerators
    RSpec.describe OnUserCreate do
      let(:user) { double('User') }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(user: user)
        end
      end

      it 'will add user to register)user_group' do
        expect { described_class.call(user: user) }.
          to change { Models::Group.count }.by(1)
      end

    end
  end
end
