require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/faculty_response_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe FacultyResponseForm do
          let(:work) { double }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('faculty_response') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            its(:model_name) { should eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(described_class.base_class).to receive(:human_attribute_name).and_call_original
              expect(described_class.human_attribute_name(:title)).to be_a(String)
            end
          end

          it { should respond_to :work }
          it { should respond_to :course }
          it { should respond_to :supervising_semester }
          it { should respond_to :nature_of_supervision }
          it { should_not be_persisted }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:course) }
          it { should validate_presence_of(:supervising_semester) }
          it { should validate_presence_of(:nature_of_supervision) }
          it { should validate_presence_of(:quality_of_research) }
          it { should validate_presence_of(:use_of_library_resources) }

          it 'will call attachments_from_work' do
            expect(repository).to receive(:work_attachments).with(work: work).and_return([double, double])
            subject.attachments
          end

          context 'assigning attachments attributes' do
            let(:attachments_attributes) do
              {
                "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
              }
            end
            subject do
              described_class.new(keywords.merge(attributes: { attachments_attributes: attachments_attributes }))
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will attach_or_update_files' do
              expect(subject.send(:attachments_extension)).to receive(:attach_or_update_files).with(
                requested_by: subject.requested_by, predicate_name: "faculty_comments_attachment"
              )
              subject.submit
            end
          end

          context '#course' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { course: 'test' }))
              expect(subject.course).to eq 'test'
            end
            it 'will fall back on #course information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'course', cardinality: 1).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.course).to eq('hello')
            end
          end

          context '#nature_of_supervision' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { nature_of_supervision: 'test' }))
              expect(subject.nature_of_supervision).to eq 'test'
            end
            it 'will fall back on #nature_of_supervision information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'nature_of_supervision', cardinality: 1
              ).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.nature_of_supervision).to eq('hello')
            end
          end

          context '#supervising_semester' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { supervising_semester: ['bogus', 'test'] }))
              expect(subject.supervising_semester).to eq ['bogus', 'test']
            end
            it 'will fall back on #supervising_semester information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'supervising_semester', cardinality: :many
              ).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.supervising_semester).to eq(['hello'])
            end
          end

          context '#quality_of_research' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { quality_of_research: 'bogus' }))
              expect(subject.quality_of_research).to eq 'bogus'
            end
            it 'will fall back on #quality_of_research information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'quality_of_research', cardinality: 1
              ).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.quality_of_research).to eq('hello')
            end
          end

          context '#use_of_library_resources' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(keywords.merge(attributes: { use_of_library_resources: 'test' }))
              expect(subject.use_of_library_resources).to eq 'test'
            end
            it 'will fall back on #use_of_library_resources information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'use_of_library_resources', cardinality: 1
              ).and_return('hello')
              subject = described_class.new(keywords)
              expect(subject.use_of_library_resources).to eq('hello')
            end
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit).to eq(false)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(
                  keywords.merge(
                    attributes: {
                      course: 'bogus', nature_of_supervision: 'nature of supervision', supervising_semester: ["bogus", "test"],
                      quality_of_research: 'test', use_of_library_resources: 'books'
                    }
                  )
                )
              end

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(5).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
