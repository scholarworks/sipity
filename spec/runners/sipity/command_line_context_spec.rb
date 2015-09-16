require 'spec_helper'

RSpec.describe Sipity::CommandLineContext do
  let(:requested_by) { Sipity::Models::Processing::Actor.new }

  subject { described_class.new(requested_by: requested_by, repository_strategy: :query) }

  its(:default_repository_strategy) { should eq(:command) }
  its(:current_user) { should eq(requested_by) }
  its(:repository) { should be_a(Sipity::QueryRepository) }

  it 'will fail to initialize with a :bogus repository strategy' do
    expect { described_class.new(username: username, repository_strategy: :bogus) }.to raise_error(NameError)
  end

end
