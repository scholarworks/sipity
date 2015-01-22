require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe CreateWorkForm do
      subject { described_class.new }

      its(:policy_enforcer) { should eq Policies::WorkPolicy }

      it 'will have a model name like Work' do
        expect(described_class.model_name).to be_a(ActiveModel::Name)
      end

      it 'will have a default #access_rights_answer' do
        expect(described_class.new.access_rights_answer).to be_present
      end

      context 'selectable answers that are an array of symbols for SimpleForm internationalization' do
        it 'will have #access_rights_answer_for_select' do
          expect(described_class.new.access_rights_answer_for_select.all? { |element| element.is_a?(Symbol) }).to be_truthy
        end

        it 'will have #work_publication_strategies_for_select' do
          expect(subject.work_publication_strategies_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
        end

        it 'will have #work_types_for_select' do
          expect(subject.work_types_for_select.all? { |strategy| strategy.is_a?(Symbol) }).to be_truthy
        end
      end

      context 'validations for' do
        context '#title' do
          it 'must be present' do
            subject.valid?
            expect(subject.errors[:title]).to be_present
          end
        end
        context '#access_rights_answer' do
          it 'must be present' do
            subject.access_rights_answer = nil
            subject.valid?
            expect(subject.errors[:access_rights_answer]).to be_present
          end
          it 'must be in the given list' do
            subject.access_rights_answer = '__not_found__'
            subject.valid?
            expect(subject.errors[:access_rights_answer]).to be_present
          end
        end
        context '#work_type' do
          it 'must be present' do
            subject.valid?
            expect(subject.errors[:work_type]).to be_present
          end
        end
        context '#work_publication_strategy' do
          it 'must be present' do
            subject.valid?
            expect(subject.errors[:work_publication_strategy]).to be_present
          end
          it 'must be from the approved list' do
            subject.work_publication_strategy = '__missing__'
            subject.valid?
            expect(subject.errors[:work_publication_strategy]).to be_present
          end
        end
        context '#publication_date' do
          it 'must be present when it was :already_published' do
            subject.work_publication_strategy = 'already_published'
            subject.valid?
            expect(subject.errors[:publication_date]).to be_present
          end
          it 'need not be present otherwise' do
            subject.valid?
            expect(subject.errors[:publication_date]).to_not be_present
          end
        end
      end

      context '#submit' do
        let(:user) { User.new(id: '123') }
        let(:repository) { CommandRepositoryInterface.new }
        subject do
          described_class.new(
            attributes: {
              title: 'This is my title',
              work_publication_strategy: 'do_not_know',
              publication_date: '2014-11-12',
              access_rights_answer: Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
            }
          )
        end
        context 'with invalid data' do
          it 'will not create a a work' do
            allow(subject).to receive(:valid?).and_return(false)
            expect { subject.submit(repository: repository, requested_by: user) }.
              to_not change { Models::Work.count }
          end
          it 'will return false' do
            allow(subject).to receive(:valid?).and_return(false)
            expect(subject.submit(repository: repository, requested_by: user)).to eq(false)
          end
        end
        context 'with valid data' do
          let(:user) { User.new(id: '123') }
          it 'will return the work having created the work, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
            allow(subject).to receive(:valid?).and_return(true)
            response = subject.submit(repository: repository, requested_by: user)
            expect(response).to be_a(Models::Work)
          end
        end
      end
    end
  end
end
