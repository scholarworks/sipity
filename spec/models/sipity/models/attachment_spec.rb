require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Attachment, type: :model do
      subject { described_class }

      its(:column_names) { should include('sip_id') }
      its(:column_names) { should include('pid') }
      its(:column_names) { should include('predicate_name') }
      its(:column_names) { should include('file_uid') }
      its(:column_names) { should include('file_name') }
      its(:primary_key) { should be_nil }
    end
  end
end
