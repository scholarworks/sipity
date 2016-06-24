require "rails_helper"
require 'sipity/guard_interface_expectation'

module Sipity
  RSpec.describe GuardInterfaceExpectation do
    let(:object) do
      Class.new do
        include GuardInterfaceExpectation
        def guard(input, *args)
          guard_interface_expectation!(input, *args)
        end

        def guard_collaborator(input, **keywords)
          guard_interface_collaborator_expectations!(input, **keywords)
        end
      end.new
    end

    context '#guard_interface_expectation!' do
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

    context '#guard_interface_collaborator_expectations!' do
      it 'will raise an exception if the input collaborating method is incorrect' do
        expect { object.guard_collaborator('hello', to_s: :empty?) }.to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
      end

      it 'will raise an exception if the input collaborating method does not exist' do
        expect { object.guard_collaborator('hello', foo: :empty?) }.to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
      end

      it 'will raise an exception if the input collaborator fails to meet a secondary condition' do
        input = double(foo: '')
        expect { object.guard_collaborator(input, foo: :present?) }.to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
      end

      it 'will work' do
        input = double(foo: 'hello')
        expect { object.guard_collaborator(input, foo: :present?) }.to_not raise_error
      end
    end
  end
end
