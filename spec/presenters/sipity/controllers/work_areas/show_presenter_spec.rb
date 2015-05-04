require 'spec_helper'

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe ShowPresenter do
        let(:context) { double('Context', view_object: view_object, current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:view_object) { double('Work Area') }
        let(:processing_actions) { double(resourceful_actions: [1]) }
        subject { described_class.new(context, view_object: view_object) }

        it 'sets the view_object' do
          expect(subject.view_object).to eq(view_object)
        end

        it 'exposes resourceful_actions' do
          allow(Decorators::ProcessingActions).to receive(:new).with(user: current_user, entity: view_object).and_return(processing_actions)
          expect(subject.resourceful_actions).to eq(processing_actions.resourceful_actions)
        end

        it 'exposes resourceful_actions?' do
          allow(Decorators::ProcessingActions).to receive(:new).with(user: current_user, entity: view_object).and_return(processing_actions)
          expect(subject.resourceful_actions?).to eq(processing_actions.resourceful_actions.present?)
        end
      end
    end
  end
end
