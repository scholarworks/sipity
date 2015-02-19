require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Group, type: :model do
      subject { described_class.new }
      its(:valid?) { should be false }
    end
  end
end
