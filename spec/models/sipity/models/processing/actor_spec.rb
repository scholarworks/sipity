require 'rails_helper'
require 'sipity/models/processing/actor'

module Sipity
  module Models
    module Processing
      RSpec.describe Actor, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include("proxy_for_id") }
        its(:column_names) { is_expected.to include("proxy_for_type") }
        its(:column_names) { is_expected.to include("name_of_proxy") }
      end
    end
  end
end
