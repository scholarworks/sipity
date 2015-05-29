require 'spec_helper'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/enrichment_action_set_presenter'

module Sipity
  module Controllers
    RSpec.describe EnrichmentActionSetPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:enrichment_action_set) do
        Parameters::ActionSetParameter.new(identifier: 'optional', collection: [double], entity: double(processing_state: 'hello'))
      end
      subject { described_class.new(context, enrichment_action_set: enrichment_action_set) }

      its(:enrichment_actions) { should eq(enrichment_action_set.collection) }
      its(:identifier) { should eq(enrichment_action_set.identifier) }
      its(:entity) { should eq(enrichment_action_set.entity) }
      its(:processing_state) { should eq(enrichment_action_set.processing_state) }
    end
  end
end