require 'spec_helper'
require 'application_controller'

RSpec.describe ApplicationController do
  context '#store_previous_path_if_applicable' do
    it 'will store the previous location if one is given' do
      allow(controller).to receive(:controller_name).and_return('cas_sessions')
      controller.params['previous_url'] = '/somewhere'
      expect(controller.send(:store_previous_path_if_applicable)).to eq(true)
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

  context '#filter_notify' do
    it 'will remove the devise messaging for failure.unauthenticated' do
      subject.flash[:alert] = subject.t('devise.failure.unauthenticated')
      expect { subject.send(:filter_notify) }.to change { subject.flash[:alert] }.to(nil)
    end
  end

  context '#authenticate_user!' do
    let(:processing_action_name) { 'fun_things' }
    context 'with Basic authentication credentials' do
      it 'will attempt to find authorize_group_from_api_key' do
        user = double('User')
        expect(controller).to(
          receive(:authorize_group_from_api_key).with(group_name: 'User', group_api_key: 'Password').and_return(user)
        )
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
        controller.authenticate_user!
        expect(controller.instance_variable_get("@current_user")).to eq(user)
      end
    end

    context 'without Basic authentication credentials' do
      it 'will attempt to find authorize_group_from_api_key' do
        expect(controller).to_not receive(:authorize_group_from_api_key)
        expect { controller.authenticate_user! }.to raise_error(StandardError)
        expect(controller.instance_variable_get("@current_user")).to eq(nil)
      end
    end
  end

  context '#current_user' do
    let(:processing_action_name) { 'fun_things' }
    context 'with Basic authentication credentials' do
      it 'will attempt to find authorize_group_from_api_key' do
        user = double('User')
        expect(controller).to(
          receive(:authorize_group_from_api_key).with(group_name: 'User', group_api_key: 'Password').and_return(user)
        )
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
        controller.current_user
        expect(controller.instance_variable_get("@current_user")).to eq(user)
      end
    end
  end

  context '#authorize_group_from_api_key' do
    let(:valid_name) { Sipity::Models::Group::BATCH_INGESTORS }
    let(:invalid_name) { 'nope' }
    it 'will equal false if its not the ETD Ingester' do
      expect(Sipity::Models::Group).to receive(:find_by).with(name: invalid_name, api_key: 'apassword').and_return(nil)
      expect(
        controller.authorize_group_from_api_key(group_name: invalid_name, group_api_key: 'apassword')
      ).to eq(false)
    end

    it 'will equal false if that password is incorrect' do
      expect(Sipity::Models::Group).to receive(:find_by).with(name: valid_name, api_key: 'nope').and_return(nil)
      expect(controller.authorize_group_from_api_key(group_name: valid_name, group_api_key: 'nope')).to eq(false)
    end

    it 'will be the ETD Ingester group if the name and password match' do
      group = double('Group')
      expect(Sipity::Models::Group).to receive(:find_by).with(name: valid_name, api_key: 'apassword').and_return(group)
      expect(
        controller.authorize_group_from_api_key(group_name: valid_name, group_api_key: 'apassword')
      ).to eq(group)
    end
  end
end
