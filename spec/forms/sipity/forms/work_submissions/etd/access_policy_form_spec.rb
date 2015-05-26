module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe AccessPolicyForm do
          let(:user) { double('User') }
          let(:work) { Models::Work.new(id: 1) }
          let(:attachment) { Models::Attachment.new(id: 2) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:copyrights) do
            [double(predicate_name: 'name', term_label: 'value', term_uri: 'code'), double]
          end
          subject { described_class.new(work: work, repository: repository) }

          before do
            allow(repository).to receive(:work_attribute_values_for).with(work: work, key: 'copyright').and_return([])
            allow(repository).to receive(:access_rights_for_accessible_objects_of).with(work: work).and_return([work, attachment])
            allow(repository).to receive(:representative_attachment_for).with(work: work).and_return(attachment)
            allow(repository).to receive(:work_attachments).with(work: work).and_return([attachment])
          end

          its(:processing_action_name) { should eq('access_policy') }
          it { should respond_to :accessible_objects_attributes= }
          it { should respond_to :copyright }
          it { should respond_to :representative_attachment_id }

          it 'will expose accessible_objects' do
            expect(subject.accessible_objects.size).to eq(2)
          end

          it 'will expose available_representative_attachments' do
            enumerable = [double]
            expect(repository).to receive(:work_attachments).and_return(enumerable)
            expect(subject.available_representative_attachments).to eq(enumerable)
          end

          it 'will validate that a copyright is given' do
            expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'copyright').and_return([])
            subject = described_class.new(work: work, repository: repository)
            subject.valid?
            expect(subject.errors[:copyright]).to be_present
          end

          it 'will validate the presence of accessible_objects_attributes' do
            subject = described_class.new(work: work, repository: repository, attributes: { accessible_objects_attributes: {} })
            subject.valid?
            expect(subject.errors[:base]).to be_present
          end

          it 'will validate the presence of a representative attachment' do
            subject = described_class.new(work: work, repository: repository, attributes: { representative_attachment_id: '' })
            subject.valid?
            expect(subject.errors[:representative_attachment_id]).to be_present
          end

          it 'will not validate the presence of a representative attachment if there are no attachments' do
            expect(repository).to receive(:work_attachments).with(work: work).and_return([])
            subject = described_class.new(work: work, repository: repository, attributes: { representative_attachment_id: '' })
            subject.valid?
            expect(subject.errors[:representative_attachment_id]).to_not be_present
          end

          it 'will validate each of the given attributes' do
            invalid_attributes = { "0" => { id: work.to_param, access_right_code: 'chici chici parm parm' } }
            subject = described_class.new(
              work: work, repository: repository, attributes: { accessible_objects_attributes: invalid_attributes }
            )
            subject.valid?
            expect(subject.errors[:accessible_objects_attributes]).to be_present
          end

          it 'will have #available_copyrights' do
            expect(repository).to receive(:get_controlled_vocabulary_entries_for_predicate_name).with(name: 'copyright').
              and_return(copyrights)
            expect(subject.available_copyrights).to eq(copyrights)
          end

          context '#submit' do
            let(:rights) { 'All rights reserved' }
            let(:attributes) do
              {
                "0" => { "id" => work.to_param, "access_right_code" => 'open_access', "release_date" => "" },
                "1" => { "id" => attachment.to_param, "access_right_code" => 'embargo_then_open_access', "release_date" => "2032-12-01" }
              }
            end
            subject do
              described_class.new(
                work: work, repository: repository, attributes: {
                  accessible_objects_attributes: attributes, copyright: rights,
                  representative_attachment_id: attachment.to_param
                }
              )
            end
            before { allow(subject).to receive(:valid?).and_return(true) }

            it 'will representative_attachment_id' do
              expect(repository).to receive(:set_as_representative_attachment).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will update_work_attribute_values!' do
              expect(repository).to receive(:update_work_attribute_values!).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will capture accessible_objects_attributes' do
              expect(repository).to receive(:apply_access_policies_to).with(
                work: work, user: user, access_policies:
                [
                  {
                    entity_id: work.to_param,
                    entity_type: Sipity::Models::Work,
                    access_right_code: 'open_access',
                    release_date: nil
                  }, {
                    entity_id: attachment.to_param,
                    entity_type: Sipity::Models::Attachment,
                    access_right_code: 'embargo_then_open_access',
                    release_date: Date.new(2032, 12, 01)
                  }
                ]
              )
              subject.submit(requested_by: user)
            end
          end
        end

        RSpec.describe AccessPolicyForm::AccessibleObjectFromInput do
          let(:attributes) { {} }
          let(:persisted_object) { double('Persisted Object', entity_type: 'Hello', human_model_name: 'Work') }
          subject { described_class.new(persisted_object, attributes) }

          its(:persisted?) { should be_truthy }
          its(:human_model_name) { should eq(persisted_object.human_model_name) }

          it 'will have a public :access_right_code' do
            expect { subject.access_right_code }.to_not raise_error
          end

          it 'will have a public :release_date' do
            expect { subject.release_date }.to_not raise_error
          end

          it 'will parse the input date' do
            subject = described_class.new(persisted_object, release_date: '2014-12-1')
            expect(subject.release_date).to eq(Date.new(2014, 12, 1))
          end

          it 'will use the persisted object entity_type if one is defined' do
            persisted_object = double(entity_type: 'Ent')
            subject = described_class.new(persisted_object)
            expect(subject.entity_type).to eq(persisted_object.entity_type)
          end

          it 'will be invalid if no access_right_code is given' do
            subject.valid?
            expect(subject.errors[:access_right_code]).to be_present
          end

          it 'will be invalid if no release_date is given for "embargo_then_open_access"' do
            subject = described_class.new(persisted_object, access_right_code: 'embargo_then_open_access')
            subject.valid?
            expect(subject.errors[:release_date]).to be_present
          end

          it 'will blank out the release date when a release date is given but the access_right_code is "open_access"' do
            subject = described_class.new(persisted_object, release_date: Time.zone.today, access_right_code: 'open_access')
            expect(subject.release_date).to_not be_present
          end

          it 'will not blank out the release date when a release date is given but no access_right_code' do
            subject = described_class.new(persisted_object, release_date: Time.zone.today)
            expect(subject.release_date).to be_present
          end

          it 'will not blank out the release date when a release date is given and access_right code is "embargo_then_open_access"' do
            subject = described_class.new(persisted_object, release_date: Time.zone.today, access_right_code: 'embargo_then_open_access')
            expect(subject.release_date).to be_present
          end

          it 'will be invalid if an incorrect access code is given' do
            subject = described_class.new(persisted_object, access_right_code: 'chocolate bunny')
            subject.valid?
            expect(subject.errors[:access_right_code]).to be_present
          end
        end
      end
    end
  end
end
