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

  it { should respond_to(:authenticate_some_outlandish_method_that_no_one_would_ever_consider_like_I_am_batman!) }

  context 'without a current user' do
    before { allow(subject).to receive(:current_user).and_return(nil) }
    its(:authenticate_user!) { should eq(false) }
    its(:authenticate_user_for_profile_management!) { should eq(false) }
  end

  context 'with a current user' do
    its(:authenticate_user!) { should eq(true) }
    its(:authenticate_user_for_profile_management!) { should eq(true) }
  end
end
