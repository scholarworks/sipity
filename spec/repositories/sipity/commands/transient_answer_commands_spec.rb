require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TransientAnswerCommands, type: :isolated_repository_module do
      context '#handle_transient_access_rights_answer' do
        Given(:entity) { Models::Work.new(id: 123) }

        context 'with an answer' do
          Given(:answer) { 'open_access' }
          When(:response) { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          Then { response.persisted? }
          And { Models::AccessRight.count == 1 }
        end
      end
    end
  end
end
