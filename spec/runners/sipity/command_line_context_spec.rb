require "rails_helper"

RSpec.describe Sipity::CommandLineContext do
  let(:requested_by) { Sipity::Models::Processing::Actor.new }

  subject { described_class.new(requested_by: requested_by, repository_strategy: :query) }

  its(:default_repository_strategy) { is_expected.to eq(:command) }
  its(:current_user) { is_expected.to eq(requested_by) }
  its(:repository) { is_expected.to be_a(Sipity::QueryRepository) }

  it 'will raise to initialize with a :bogus repository strategy' do
    expect { described_class.new(username: username, repository_strategy: :bogus) }.to raise_error(NameError)
  end

  it { is_expected.not_to respond_to(:some_random_authenticate_thing!) }

  it 'will raise an exception on other missing methods' do
    expect { subject.some_random_authenticate_thing! }.to raise_error(NoMethodError)
  end

  it { is_expected.to respond_to(:authenticate_some_outlandish_method_that_no_one_would_ever_consider_like_I_am_batman!) }

  context 'without a current user' do
    before { allow(subject).to receive(:current_user).and_return(nil) }
    its(:authenticate_user!) { is_expected.to eq(false) }
    its(:authenticate_user_for_profile_management!) { is_expected.to eq(false) }
  end

  context 'with a current user' do
    its(:authenticate_user!) { is_expected.to eq(true) }
    its(:authenticate_user_for_profile_management!) { is_expected.to eq(true) }
  end
end
