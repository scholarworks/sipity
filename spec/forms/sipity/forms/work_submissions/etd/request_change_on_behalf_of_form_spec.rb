require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RequestChangeOnBehalfOfForm do
          let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
          let(:work) { double('Work', to_processing_entity: processing_entity) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: 'hello') }
          let(:user) { User.new(id: 1) }
          subject { described_class.new(work: work, repository: repository) }

          before do
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:valid_on_behalf_of_collaborator_ids).and_return([someone.id])
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:valid_on_behalf_of_collaborators).and_return([someone])
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:on_behalf_of_collaborator).and_return(someone)
          end

          let(:someone) { double(id: 'one') }

          context '#render' do
            let(:f) { double }
            it 'will render HTML safe comment textarea and comment selection box' do
              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              expect(f).to receive(:input).with(:on_behalf_of_collaborator_id, collection: [someone], value_method: :id).
                and_return("<input />")
              subject.render(f: f)
            end
          end

          its(:comment_legend) { should be_html_safe }

          context 'validations' do
            it 'will require a comment' do
              subject = described_class.new(work: work, repository: repository, attributes: { comment: nil })
              subject.valid?
              expect(subject.errors[:comment]).to be_present
            end

            it 'will require an on_behalf_of_collaborator_id' do
              subject = described_class.new(work: work, repository: repository, attributes: { on_behalf_of_collaborator_id: nil })
              subject.valid?
              expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
            end

            it 'will requires a valid on_behalf_of_collaborator_id' do
              subject = described_class.new(
                work: work, repository: repository, attributes: { on_behalf_of_collaborator_id: someone.id * 2 }
              )
              subject.valid?
              expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
            end
          end

          context 'with valid data' do
            subject do
              described_class.new(
                work: work, repository: repository, attributes: { comment: 'Comments!', on_behalf_of_collaborator_id: someone.id }
              )
            end
            let(:a_processing_comment) { double }
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will delegate to Services::RequestChangesViaCommentService' do
              expect(Services::RequestChangesViaCommentService).to receive(:call)
              expect(subject.submit(requested_by: user)).to eq(work)
            end
          end
        end
      end
    end
  end
end
