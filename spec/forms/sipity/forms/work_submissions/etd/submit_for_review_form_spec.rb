require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe SubmitForReviewForm do
          let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
          let(:work) { double('Work', to_processing_entity: processing_entity) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id) }
          let(:user) { User.new(id: 1) }
          subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

          it 'validates the aggreement to the submission terms' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            subject.valid?
            expect(subject.errors[:agree_to_terms_of_deposit]).to be_present
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:agree_to_terms_of_deposit, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          it { should delegate_method(:submit).to(:processing_action_form) }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }
        end
      end
    end
  end
end
