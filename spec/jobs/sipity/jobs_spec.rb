require 'spec_helper'
require 'sipity/jobs'

module Sipity
  RSpec.describe Jobs do
    context '.submit' do
      it 'will find the corresponding job then submit it' do
        expect(Jobs::DoiCreationRequestJob).to receive(:submit).with(123)
        described_class.submit('doi_creation_request_job', 123)
      end

      it 'will raise a Name Error if the job does not exist' do
        expect { described_class.submit('i_dont_want_to_work') }.to raise_error(Exceptions::JobNotFoundError)
      end
    end
  end
end
