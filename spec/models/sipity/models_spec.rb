require 'spec_helper'
require 'sipity/models'

module Sipity
  RSpec.describe Models do
    it 'will use use_relative_model_naming to appeas the Rails monster' do
      expect(described_class.use_relative_model_naming?).to be_truthy
    end
  end
end
