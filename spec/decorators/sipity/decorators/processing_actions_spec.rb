require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe ProcessingActions do
      before do
        Sipity::SpecSupport.load_database_seeds!(seeds_path: 'spec/fixtures/seeds/trigger_work_state_change.rb')
      end

      let(:commands) { CommandRepository.new }
      let(:user) { User.create!(username: 'user') }

      let!(:entity) do
        work = commands.create_work!(title: 'Book', work_type: 'etd', work_publication_strategy: 'will_not_publish')
        commands.grant_creating_user_permission_for!(entity: work, user: user)
        work
      end

      subject { described_class.new(user: user, entity: entity) }

      its(:enrichment_actions) { should be_a Enumerable }
      its(:resourceful_actions) { should be_a Enumerable }
      its(:state_advancing_actions) { should be_a Enumerable }
    end
  end
end
