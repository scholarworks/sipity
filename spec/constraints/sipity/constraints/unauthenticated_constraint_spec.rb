require 'spec_helper'
require 'sipity/constraints/unauthenticated_constraint'

module Sipity
  module Constraints
    RSpec.describe UnauthenticatedConstraint do
      context '.matches?' do
        [
          [true, -> { {} }],
          [true, -> { { 'warden' => nil } }],
          [true, -> { { 'warden' => double(user: nil) } }],
          [false, -> { { 'warden' => double(user: 'name') } }],
          [true, -> { { 'rack.session' => {} } }],
          [true, -> { { 'rack.session' => { 'cogitate_data' => nil } } }],
          [false, -> { { 'rack.session' => { 'cogitate_data' => :logged_ind } } }]
        ].each do |expected, env|
          it "will be #{expected.inspect} with env = #{env.inspect}" do
            request = double(env: instance_exec(&env))
            expect(subject.matches?(request)).to eq(expected)
          end
        end
      end
    end
  end
end
