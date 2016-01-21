require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/submission_windows/ulra/start_a_submission_form'

module Sipity
  module Forms
    module SubmissionWindows
      module Ulra
        RSpec.describe StartASubmissionForm do
          let(:keywords) { { repository: repository, submission_window: submission_window, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:submission_window) { Models::SubmissionWindow.new(id: 1, work_area: work_area, slug: '1234') }
          let(:work_area) { Models::WorkArea.new(id: 2, slug: described_class::DEFAULT_WORK_AREA_SLUG) }
          before do
            allow(repository).to receive(:find_work_area_by).with(slug: work_area.slug).and_return(work_area)
            allow(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').and_return([])
          end

          it { should implement_processing_form_interface }
          its(:public_methods) { should include(:to_work_area) }

          context 'its class configuration' do
            subject { described_class }
            its(:base_class) { should eq(Models::Work) }
            its(:model_name) { should eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(Models::Work).to receive(:human_attribute_name).and_call_original
              expect(subject.human_attribute_name(:title)).to be_a(String)
            end
          end

          its(:policy_enforcer) { should eq Policies::SubmissionWindowPolicy }
          its(:base_class) { should eq Models::Work }
          its(:default_repository) { should respond_to :create_work! }
          its(:default_repository) { should respond_to :find_submission_window_by }
          its(:processing_subject_name) { should eq :submission_window }
          its(:entity) { should eq submission_window }
          its(:to_work_area) { should eq(work_area) }
          its(:persisted?) { should eq(false) }

          it 'will delegate #to_processing_entity to the submission window' do
            expect(submission_window).to receive(:to_processing_entity)
            subject.to_processing_entity
          end

          it 'will have a model name like Work' do
            expect(described_class.model_name).to be_a(ActiveModel::Name)
          end

          it 'will have #award_categories_for_select' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'award_category').
              and_return(['award_category', 'bogus'])
            expect(subject.award_categories_for_select).to be_a(Array)
          end

          context 'validations' do
            let(:attributes) { { title: nil, access_rights_answer: nil } }
            subject { described_class.new(keywords) }
            include Shoulda::Matchers::ActiveModel
            it { should validate_presence_of(:title) }
            it { should validate_presence_of(:advisor_netid) }
            it { should validate_presence_of(:award_category) }
            it { should validate_presence_of(:work_type) }
            it { should validate_presence_of(:course_name) }
            it { should validate_presence_of(:course_number) }
            it 'should validate submission_window_is_open' do
              expect_any_instance_of(OpenForStartingSubmissionsValidator).to receive(:validate_each)
              subject.valid?
            end
          end

          context '#submit' do
            subject { described_class.new(keywords) }
            context 'with invalid data' do
              let(:attributes) do
                { title: "This is my title", advisor_name: 'a name', advisor_netid: 'dummy_id', award_category: 'some_category' }
              end
              it 'will not create a a work' do
                allow(subject).to receive(:valid?).and_return(false)
                expect { subject.submit }.
                  to_not change { Models::Work.count }
              end
              it 'will return false' do
                allow(subject).to receive(:valid?).and_return(false)
                expect(subject.submit).to eq(false)
              end
            end
            context 'with valid data' do
              let(:user) { User.new(id: '123') }
              let(:work) { Sipity::Models::Work.new(id: 1) }
              let(:attributes) do
                {
                  title: 'Hello', access_rights_answer: 'right answer', advisor_name: 'a name',
                  course_name: 'a name', course_number: 'a number', award_category: 'a category', advisor_netid: 'a netid'
                }
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(repository).to receive(:create_work!).and_return(work)
                allow(repository).to receive(:register_action_taken_on_entity)
              end

              it 'will return the work' do
                expect(repository).to receive(:create_work!).and_return(work)
                response = subject.submit
                expect(response).to eq(work)
              end

              it 'will log the event' do
                expect(repository).to receive(:log_event!).and_call_original
                subject.submit
              end

              it 'will grant creating user permission for' do
                expect(repository).to receive(:grant_creating_user_permission_for!).and_call_original
                subject.submit
              end

              it 'will also register the action on the work' do
                expect(repository).to receive(:register_action_taken_on_entity).with(
                  entity: work, action: subject.processing_action_name, requested_by: user
                ).and_call_original
                subject.submit
              end

              it 'will register the action on the submission window' do
                expect(repository).to receive(:register_action_taken_on_entity).
                  with(entity: submission_window, action: subject.processing_action_name, requested_by: user).
                  and_call_original
                subject.submit
              end

              it 'will register the project_information action on the work' do
                expect(repository).to receive(:register_action_taken_on_entity).
                  with(entity: work, action: 'project_information', requested_by: user).
                  and_call_original
                subject.submit
              end

              it 'will assiassign_collaborators_to the given work' do
                expect(repository).to receive(:assign_collaborators_to).with(
                  work: work, collaborators: kind_of(Models::Collaborator)
                ).and_call_original
                subject.submit
              end

              it 'will use a valid collaborator' do
                collaborator = subject.send(:build_collaborator, work: work)
                expect(collaborator).to be_valid
                expect(collaborator).to be_responsible_for_review
              end

              it 'will persist the additional attributes of course_name, course_number, and award_category' do
                expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'course_name', values: 'a name')
                expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'course_number', values: 'a number')
                expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'award_category', values: 'a category')
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
