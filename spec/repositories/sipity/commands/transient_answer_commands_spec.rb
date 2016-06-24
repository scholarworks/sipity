require "rails_helper"
require 'sipity/commands/transient_answer_commands'

module Sipity
  module Commands
    RSpec.describe TransientAnswerCommands, type: :isolated_repository_module do
      context '#handle_transient_access_rights_answer' do
        let(:entity) { Models::Work.new(id: 123) }

        context 'with an answer' do
          let(:answer) { 'open_access' }
          subject { test_repository.handle_transient_access_rights_answer(entity: entity, answer: answer) }
          it { is_expected.to be_persisted }
          it 'should change the Models::AccessRight.count' do
            expect { subject }.to change(Models::AccessRight, :count).by(1)
          end
        end
      end
    end
  end
end
