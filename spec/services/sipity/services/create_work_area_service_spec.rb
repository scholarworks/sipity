require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkAreaService do
      it 'will create the bare-bones entries based on the slug' do
        expect do
          expect(described_class.call(slug: 'worm')).to be_a(Models::WorkArea)
        end.to change { Models::WorkArea.count }.by(1)
      end

      let(:actor) { Models::Processing::Actor.new(id: 2, proxy_for_id: 3, proxy_for_type: 'User') }
      it 'will grant permission specific permission but not general permission' do
        work_area = described_class.call(slug: 'worm', work_area_managers: actor)

        expect(
          Models::Processing::EntitySpecificResponsibility.where(
            entity: work_area.processing_entity,
            actor_id: actor.id
          ).count
        ).to eq(1)

        expect(Models::Processing::StrategyResponsibility.count).to eq(0)
      end
    end
  end
end
