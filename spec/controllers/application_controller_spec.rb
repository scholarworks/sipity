require 'spec_helper'

RSpec.describe ApplicationController do
  context '#runner' do
    it 'can be replaced at runtime' do
      controller.runner = :my_runner
      expect(controller.runner).to eq(:my_runner)
    end
    it 'raises a RunnerNotFoundError when the runner is not found in the container' do
      allow(controller).to receive(:action_name).and_return('missing')
      controller.runner_container = Sip
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
end
