require "rails_helper"
require 'sipity/controllers/debug_actor_presenter'

module Sipity
  module Controllers
    RSpec.describe DebugActorPresenter, type: :presenter do
      let(:actor) do
        double(id: '456', proxy_for: double, proxy_for_type: :true, proxy_for_id: true, actor_processing_relationship: 'hello')
      end
      let(:context) { PresenterHelper::Context.new }
      let(:repository) { QueryRepositoryInterface.new }
      subject do
        described_class.new(context, debug_actor: actor)
      end

      its(:name) { is_expected.to eq(actor.proxy_for.to_s) }
      it { is_expected.to delegate_method(:proxy_for_type).to(:debug_actor) }
      it { is_expected.to delegate_method(:proxy_for_id).to(:debug_actor) }
      it { is_expected.to delegate_method(:actor_processing_relationship).to(:debug_actor) }
      it { is_expected.to delegate_method(:actor_id).to(:debug_actor).as(:id) }

      it 'will guard the interface of the actor' do
        expect { described_class.new(context, debug_actor: double) }.to raise_error(Exceptions::InterfaceExpectationError)
      end
    end
  end
end
