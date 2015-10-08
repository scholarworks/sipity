require 'spec_helper'
require 'application_controller'

RSpec.describe ApplicationController do
  context '#with_authentication_hack_to_remove_warden' do
    it 'will not yield when the given status is :unauthenticated' do
      expect { |b| controller.with_authentication_hack_to_remove_warden(:unauthenticated, &b) }.to_not yield_control
    end
    it 'will yield when the given status is something other than :unauthenticated' do
      expect { |b| controller.with_authentication_hack_to_remove_warden(nil, &b) }.to yield_control
    end
  end

  context '#current_user' do
    it 'will not call the CurrentAgentFromSessionExtractor if @current_user is set' do
      user = double('User')
      controller.send(:current_user=, user)
      expect(Sipity::Services::CurrentAgentFromSessionExtractor).to_not receive(:call)
      controller.current_user
    end

    it 'will set the @current_user via CurrentAgentFromSessionExtractor one is not already set' do
      user = double('User')
      expect(Sipity::Services::CurrentAgentFromSessionExtractor).to receive(:call).with(session: controller.session).and_return(user)
      controller.current_user
      expect(controller.instance_variable_get("@current_user")).to eq(user)
    end
  end
  context '#repository' do
    it 'will be a QueryRepository for a GET request' do
      expect(request).to receive(:get?).and_return(true)
      expect(controller.repository).to be_a(Sipity::QueryRepository)
    end
    it 'will be a Repository for a non-GET request' do
      expect(request).to receive(:get?).and_return(false)
      expect(controller.repository).to be_a(Sipity::CommandRepository)
    end
  end
  context '#runner' do
    it 'can be replaced at runtime' do
      my_runner = double(run: true)
      controller.runner = my_runner
      expect(controller.runner).to eq(my_runner)
    end
    it 'raises a RunnerNotFoundError when the runner is not found in the container' do
      allow(controller).to receive(:action_name).and_return('missing')
      controller.runner_container = Sipity
      expect { controller.runner }.to raise_error(ApplicationController::RunnerNotFoundError)
    end

    it 'requires a #runner_container to be defined' do
      allow(controller).to receive(:action_name).and_return('missing')
      expect { controller.runner }.to raise_error(NoMethodError)
    end
  end
  describe 'RunnerNotFoundError' do
    subject { ApplicationController::RunnerNotFoundError.new(name: 'MyName', container: 'MyContainer') }
    it 'has a meaningful message' do
      expect(subject.to_s).to eq("Unable to find MyName in MyContainer")
    end
  end

  it { should delegate_method(:signed_in?).to(:current_user) }
  its(:public_methods) { should include(:current_user) }
  its(:public_methods) { should include(:signed_in?) }
  its(:public_methods) { should_not include(:current_user=) }
  its(:private_methods) { should include(:current_user=) }
end
