require 'spec_helper'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/enrichment_action_presenter'

module Sipity
  module Controllers
    RSpec.describe EnrichmentActionPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:enrichment_action) { Models::Processing::StrategyAction.new(name: 'create_a_window') }
      subject { described_class.new(context, enrichment_action: enrichment_action) }

      its(:default_repository) { should respond_to(:scope_statetegy_actions_that_have_occurred) }

      it "will require you to implement an #entity" do
        expect { subject.send(:entity) }.to raise_error(NotImplementedError)
      end

      its(:action_name) { should eq(enrichment_action.name) }
    end
  end
end
