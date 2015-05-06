require 'spec_helper'

RSpec.describe Sipity do
  subject { described_class }
  its(:table_name_prefix) { should eq('sipity_') }
end
