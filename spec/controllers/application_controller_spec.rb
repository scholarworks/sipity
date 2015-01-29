require 'spec_helper'

RSpec.describe ApplicationController do
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
end
