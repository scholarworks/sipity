require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TodoListCommands, type: :repository_methods do
      let(:work) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }

      context '#create_work_todo_list_for_current_state' do
        it 'will persist TodoItemState items' do
          expect { test_repository.create_work_todo_list_for_current_state(work: work) }.
            to change { Models::TodoItemState.count }
        end
      end
    end
  end
end
