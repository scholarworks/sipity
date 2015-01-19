require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_repository do
      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the work'
      end

      context '#update_processing_state!' do
        let(:work) { Models::Work.create! }
        it 'will update the underlying state of the object' do
          expect { test_repository.update_processing_state!(work: work, new_processing_state: 'hello') }.
            to change { work.processing_state }.to('hello')
        end
      end
    end
  end
end
