require "rails_helper"
require 'sipity/constraints/unauthenticated_constraint'

module Sipity
  module Constraints
    RSpec.describe UnauthenticatedConstraint do
      context '.matches?' do
        it 'will be true if there is no warden environment' do
          request = double(env: {})
          expect(subject.matches?(request)).to eq(true)
        end

        it 'will be true warden does not have a user' do
          request = double(env: { 'warden' => nil })
          expect(subject.matches?(request)).to eq(true)
        end

        it 'will be true warden user is nil' do
          request = double(env: { 'warden' => double(user: nil) })
          expect(subject.matches?(request)).to eq(true)
        end

        it 'will be false if warden has a user (that is someone is authenticated)' do
          request = double(env: { 'warden' => double(user: 'Hello') })
          expect(subject.matches?(request)).to eq(false)
        end
      end
    end
  end
end
