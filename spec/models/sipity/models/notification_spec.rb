require 'spec_helper'
require 'sipity/models/notification'

module Sipity
  module Models
    RSpec.describe Notification do
      subject { described_class }
      its(:table_name_prefix) { should eq('sipity_notification_') }
    end
  end
end
