require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/processing_hooks/etd/works/grad_school_signoff_processing_hook'

module Sipity
  module ProcessingHooks
    module Etd
      module Works
        RSpec.describe GradSchoolSignoffProcessingHook do
          context '.call' do
            let(:repository) { CommandRepositoryInterface.new }
            let(:work) { double }
            let(:entity) { double(proxy_for: work) }
            let(:as_fo_date) { Time.zone.today }
            subject { described_class }
            it 'will create a "submission_date" entry on the associated work' do
              expect(repository).to receive(:update_work_attribute_values!).
                with(
                  work: work,
                  key: Models::AdditionalAttribute::ETD_REVIEWER_SIGNOFF_DATE,
                  values: as_fo_date.strftime(Models::AdditionalAttribute::DATE_FORMAT)
                ).and_call_original
              subject.call(as_fo_date: as_fo_date, entity: entity, repository: repository)
            end

            its(:default_repository) { is_expected.to respond_to(:update_work_attribute_values!) }
            its(:default_as_of_date) { is_expected.to be_a(Date) }
          end
        end
      end
    end
  end
end
