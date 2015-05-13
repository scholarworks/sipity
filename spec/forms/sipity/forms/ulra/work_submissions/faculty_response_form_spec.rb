require 'spec_helper'

module Sipity
  module Forms
    module Ulra
      module WorkSubmissions
        RSpec.describe FacultyResponseForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:enrichment_type) { should eq('faculty_response') }
          its(:policy_enforcer) { should eq Policies::Processing::ProcessingEntityPolicy }

          it { should respond_to :work }
          it { should respond_to :course }
          it { should respond_to :supervising_semester }
          it { should respond_to :nature_of_supervision }

          it 'will require course, supervising_semester and nature_of_supervision' do
            subject.valid?
            expect(subject.errors[:course]).to be_present
            expect(subject.errors[:supervising_semester]).to be_present
            expect(subject.errors[:nature_of_supervision]).to be_present
            expect(subject.errors[:quality_of_research]).to be_present
            expect(subject.errors[:use_of_library_resources]).to be_present
          end

          it 'will call attachments_from_work' do
            expect(repository).to receive(:work_attachments).with(work: work).and_return([double, double])
            subject.attachments
          end

          context 'assigning attachments attributes' do
            let(:user) { double('User') }
            let(:attachments_attributes) do
              {
                "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
              }
            end
            subject { described_class.new(work: work, attachments_attributes: attachments_attributes, repository: repository) }

            before do
              allow(subject).to receive(:valid?).and_return(true)
            end

            it 'will delete any attachments marked for deletion' do
              expect(repository).to receive(:remove_files_from).with(work: work, user: user, pids: ["i8tnddObffbIfNgylX7zSA=="])
              subject.submit(requested_by: user)
            end

            it 'will amend any attachment metadata' do
              expect(repository).to receive(:amend_files_metadata).with(
                work: work, user: user, metadata: {
                  "y5Fm8YK9-ekjEwUMKeeutw==" => { "name" => "hotel.pdf" },
                  "64Y9v5yGshHFgE6fS4FRew==" => { "name" => "code4lib.pdf" }
                }
              )
              subject.submit(requested_by: user)
            end
          end

          context '#course' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, course: 'test', repository: repository)
              expect(subject.course).to eq 'test'
            end
            it 'will fall back on #course information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'course').and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.course).to eq('hello')
            end
          end

          context '#nature_of_supervision' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, nature_of_supervision: 'test', repository: repository)
              expect(subject.nature_of_supervision).to eq 'test'
            end
            it 'will fall back on #nature_of_supervision information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'nature_of_supervision'
              ).and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.nature_of_supervision).to eq('hello')
            end
          end

          context '#supervising_semester' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, supervising_semester: ['bogus', 'test'], repository: repository)
              expect(subject.supervising_semester).to eq ['bogus', 'test']
            end
            it 'will fall back on #supervising_semester information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'supervising_semester'
              ).and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.supervising_semester).to eq(['hello'])
            end
          end

          context '#quality_of_research' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, quality_of_research: 'bogus', repository: repository)
              expect(subject.quality_of_research).to eq 'bogus'
            end
            it 'will fall back on #quality_of_research information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'quality_of_research'
              ).and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.quality_of_research).to eq('hello')
            end
          end

          context '#use_of_library_resources' do
            before do
              allow(repository).to receive(:work_attribute_values_for)
            end
            it 'will be the input via the #form' do
              subject = described_class.new(work: work, use_of_library_resources: 'test', repository: repository)
              expect(subject.use_of_library_resources).to eq 'test'
            end
            it 'will fall back on #use_of_library_resources information associated with the work' do
              expect(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'use_of_library_resources'
              ).and_return('hello')
              subject = described_class.new(work: work, repository: repository)
              expect(subject.use_of_library_resources).to eq('hello')
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit(requested_by: user))
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(
                  work: work, course: 'bogus', nature_of_supervision: 'nature of supervision',
                  supervising_semester: ["bogus", "test"], quality_of_research: 'test',
                  use_of_library_resources: 'books', repository: repository
                )
              end
              before do
                expect(subject).to receive(:valid?).and_return(true)
              end

              it 'will return the work' do
                returned_value = subject.submit(requested_by: user)
                expect(returned_value).to eq(work)
              end

              it "will transition the work's corresponding enrichment todo item to :done" do
                expect(repository).to receive(:register_action_taken_on_entity).and_call_original
                subject.submit(requested_by: user)
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(5).and_call_original
                subject.submit(requested_by: user)
              end

              it 'will record the event' do
                expect(repository).to receive(:log_event!).and_call_original
                subject.submit(requested_by: user)
              end
            end
          end
        end
      end
    end
  end
end
