require "rails_helper"
require 'sipity/queries/redirect_queries'

module Sipity
  module Queries
    RSpec.describe RedirectQueries, type: :isolated_repository_module do
      before do
        test_repository.extend(Sipity::Commands::RedirectCommands)
      end
      let(:work) { Models::Work.new(id: 1) }
      let(:url) { 'https://hello.com' }

      context '#active_redirect_for' do
        it 'will find the most relevant redirect' do
          _prior = test_repository.create_redirect_for(work: work, url: 'first', as_of: 3.days.ago.to_date)
          current = test_repository.create_redirect_for(work: work, url: 'second', as_of: 2.days.ago.to_date)
          _upcoming = test_repository.create_redirect_for(work: work, url: 'third', as_of: 2.days.from_now.to_date)
          expect(test_repository.active_redirect_for(work_id: work.id)).to eq(current)
          expect(test_repository.active_redirect_for(work_id: work.id, as_of: 5.days.ago.to_date)).to be_nil
        end
      end
    end
  end
end
