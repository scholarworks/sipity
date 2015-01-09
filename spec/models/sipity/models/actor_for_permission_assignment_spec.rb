require 'rails_helper'

module Sipity
  module Models
    RSpec.describe ActorForPermissionAssignment, type: :model do
      subject { described_class }
      its(:column_names) { should include('actor_id') }
      its(:column_names) { should include('actor_type') }
      its(:column_names) { should include('acting_as') }
      its(:column_names) { should include('work_type') }
    end
  end
end
