require 'spec_helper'
module Sipity
  module Services
    RSpec.describe UserSignsOffOnBehalfOfCollaborator do
      let(:form) { double('Form', resulting_strategy_state: 'chubacabra') }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { double('User') }

      subject { described_class.new(form: form, repository: repository, requested_by: requested_by) }

      context '.call' do
        it 'is a wrapper' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(form: form, repository: repository, requested_by: requested_by)
        end
      end
    end
  end
end