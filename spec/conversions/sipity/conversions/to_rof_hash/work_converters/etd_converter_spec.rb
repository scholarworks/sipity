require 'spec_helper'
require 'sipity/conversions/to_rof_hash/work_converters/etd_converter'

module Sipity
  module Conversions
    module ToRofHash
      module WorkConverters
        RSpec.describe EtdConverter do
          let(:work) do
            Sipity::Models::Work.new(
              id: 'abcd-ef',
              work_type: 'doctoral_dissertation',
              collaborators: [collaborator],
              access_right: access_right,
              created_at: Time.zone.today
            )
          end
          let(:access_right) { Sipity::Models::AccessRight.new(access_right_code: Sipity::Models::AccessRight::OPEN_ACCESS) }
          let(:collaborator) { Sipity::Models::Collaborator.new(role: 'Research Director', name: 'Alexander Hamilton') }
          let(:repository) { Sipity::QueryRepositoryInterface.new }

          subject { described_class.new(work: work, repository: repository) }

          its(:default_repository) { is_expected.to respond_to :work_attachments }
          its(:af_model) { is_expected.to eq('Etd') }
          its(:edit_groups) { is_expected.to be_a(Array) }
          its(:metadata) { is_expected.to be_a(Hash) }
          its(:rels_ext) { is_expected.to be_a(Hash) }
          its(:to_hash) { is_expected.to be_a(Hash) }

          context '#attachments' do
            it 'should retrieve all attachments' do
              expect(repository).to receive(:work_attachments).with(work: work, predicate_name: :all).return(:returned_value)
              expect(subject.attachments).to be_a(Array)
            end
          end
        end
      end
    end
  end
end
