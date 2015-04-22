require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkAreaService do
      it 'will create the bare-bones entries based on the slug' do
        expect do
          expect(described_class.call(slug: 'worm')).to be_a(Models::WorkArea)
        end.to change { Models::WorkArea.count }.by(1)
      end
    end
  end
end
