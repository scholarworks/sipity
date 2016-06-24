require "rails_helper"
require 'sipity/models/work'

RSpec.describe Sipity::Models::WorkRedirectStrategy, type: :model do
  context 'class configuration' do
    subject { described_class }
    its(:table_name) { is_expected.to eq('sipity_work_redirect_strategies') }
  end
  context 'an instance' do
    subject { described_class.new }
    it { is_expected.to belong_to :work }
    it { is_expected.to delegate_method(:to_work_area).to(:work).as(:work_area) }
  end
end
