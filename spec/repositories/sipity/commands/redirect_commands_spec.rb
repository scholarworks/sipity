require "rails_helper"
require 'sipity/commands/redirect_commands'

module Sipity
  module Commands
    RSpec.describe RedirectCommands, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 1) }
      let(:url) { 'https://hello.com' }

      context '#create_redirect_for' do
        let(:as_of) { Time.zone.today }

        it 'will add a record starting on the given date' do
          expect { test_repository.create_redirect_for(work: work, url: url, as_of: as_of) }.
            to change { Sipity::Models::WorkRedirectStrategy.count }.by(1)
        end

        it 'will add an end date to a record for the work that does not have an end date' do
          past_date = 3.days.ago.to_date
          test_repository.create_redirect_for(work: work, url: url, as_of: 5.days.ago)
          previous = test_repository.create_redirect_for(work: work, url: url, as_of: past_date)
          test_repository.create_redirect_for(work: work, url: url, as_of: as_of)
          expect(previous.reload.end_date).to eq(as_of)
        end

        it 'will add an end date to the new record if there is a start date in the future of the given date' do
          future_date = 3.days.from_now.to_date
          test_repository.create_redirect_for(work: work, url: url, as_of: future_date)
          test_repository.create_redirect_for(work: work, url: url, as_of: 5.days.from_now.to_date)
          redirect_strategy = test_repository.create_redirect_for(work: work, url: url, as_of: as_of)
          expect(redirect_strategy.end_date).to eq(future_date)
        end
      end
    end
  end
end
