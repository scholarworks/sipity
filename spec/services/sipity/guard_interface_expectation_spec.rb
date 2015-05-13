require 'spec_helper'

module Sipity
  RSpec.describe GuardInterfaceExpectation do
    let(:object) do
      Class.new do
        include GuardInterfaceExpectation
        def guard(input, *args)
          guard_interface_expectation!(input, *args)
        end
      end.new
    end

    it 'will raise an exception if the input does not respond to the given method' do
      expect { object.guard('hello', :foo) }.to raise_error(Exceptions::InterfaceExpectationError)
    end

    it 'will raise an exception if the input does not respond to one of the given methods' do
      expect { object.guard(double(foo: true), :foo, :bar) }.to raise_error(Exceptions::InterfaceExpectationError)
    end

    it 'will not raise an exception if the input responds to all methods (and more)' do
      expect { object.guard(double(foo: true, bar: true, baz: true), :foo, :bar) }.to_not raise_error
    end
  end
end
