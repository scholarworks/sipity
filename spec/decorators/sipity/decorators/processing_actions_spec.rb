require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe ProcessingActions do
      # TODO: This class is behaving like a massive integration test. Too many
      #   things are happening.
      let(:repository) { CommandRepository.new }
      let(:user) { User.create!(username: 'user') }
      let(:action_decorator) { double(call: an_action) }
      let(:an_action) { double(action_type: Models::Processing::StrategyAction::ENRICHMENT_ACTION) }
      let(:work_area) do
        Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: 'etd')
      end
      let(:submission_window) do
        Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(slug: 'start', work_area: work_area)
      end

      let!(:entity) do
        work = repository.create_work!(
          submission_window: submission_window,
          title: 'Book',
          work_type: 'doctoral_dissertation',
          work_publication_strategy: 'will_not_publish'
        )
        repository.grant_creating_user_permission_for!(entity: work, user: user)
        work
      end

      subject { described_class.new(user: user, entity: entity, repository: repository, action_decorator: action_decorator) }

      it 'will generate various action groups' do
        expect(subject.enrichment_actions).to be_a Enumerable
        expect(subject.resourceful_actions).to be_a Enumerable
        expect(subject.state_advancing_actions).to be_a Enumerable
      end
    end
  end
end
