require "rails_helper"
require 'sipity/models/group_membership'

module Sipity
  module Models
    RSpec.describe GroupMembership do
      subject { described_class.new }
      it 'will raise an ArgumentError if you provide an invalid membership_role' do
        expect { subject.membership_role = '__incorrect_role__' }.to raise_error(ArgumentError)
      end

      it 'will initialize with a default membership_role' do
        expect(subject.membership_role).to be_present
      end
    end
  end
end
