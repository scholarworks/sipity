require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe CreateSipForm do
      subject { described_class.new }

      its(:policy_enforcer) { should eq Policies::SipPolicy }

      it 'will have a model name like Sip' do
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
    end
  end
end
