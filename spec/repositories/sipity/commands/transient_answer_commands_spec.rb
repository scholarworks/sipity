require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TransientAnswerCommands, type: :repository_methods do
      context '#handle_transient_access_rights_answer' do
        Given(:entity) { Models::Work.new(id: 123) }

        context 'with "open_access" answer' do
          Given(:answer) { 'open_access' }
          When(:response) { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          Then { response.persisted? }
          And { Models::AccessRight.count == 1 }
        end

        context 'with "restricted_access" answer' do
          Given(:answer) { 'restricted_access' }
          When(:response) { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          Then { response.persisted? }
          And { Models::AccessRight.count == 1 }
        end

        context 'with "private_access" answer' do
          Given(:answer) { 'private_access' }
          When(:response) { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          Then { response.persisted? }
          And { Models::AccessRight.count == 1 }
        end

        context 'with "access_changes_over_time" answer' do
          Given(:answer) { 'access_changes_over_time' }
          Invariant { Models::AccessRight.count }
          When(:response) { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          Then { response.persisted? }
        end
      end
    end
  end
end
