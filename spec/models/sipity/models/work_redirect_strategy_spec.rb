require 'spec_helper'
require 'sipity/models/work'

RSpec.describe Sipity::Models::WorkRedirectStrategy, type: :model do
  context 'class configuration' do
    subject { described_class }
    its(:table_name) { should eq('sipity_work_redirect_strategies') }
  end
  context 'an instance' do
    subject { described_class.new }
    it { should belong_to :work }
  end
end
