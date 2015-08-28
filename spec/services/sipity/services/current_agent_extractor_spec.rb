require 'spec_helper'
require 'sipity/services/current_agent_extractor'
require 'sipity/models/agent'

RSpec.describe Sipity::Services::CurrentAgentFromSessionExtractor do
  subject { described_class }
  let(:agent) { double(user_signed_in?: true, agreed_to_application_terms_of_service?: true) }

  [
    { session: { cogitate_token: 'a token' }, method_name: :new_from_cogitate_token },
    { session: { validated_resource_id: 1 }, method_name: :new_from_user_id },
    { session: { 'warden.user.user.key' => [[1], nil] }, method_name: :new_from_user_id },
    { session: {}, method_name: :new_null_agent }
  ].each do |test_case|
    it "will use Sipity::Models::Agent.#{test_case.fetch(:method_name)} for session = #{test_case.fetch(:session).inspect}" do
      expect(Sipity::Models::Agent).to receive(test_case.fetch(:method_name)).and_return(agent)
      described_class.call(session: test_case.fetch(:session))
    end
  end
end
