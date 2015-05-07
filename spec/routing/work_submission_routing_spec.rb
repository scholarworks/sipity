require 'spec_helper'

describe 'work area routing spec' do
  context 'sipity/controllers/work_submissions' do
    let(:controller) { 'sipity/controllers/work_submissions' }
    [
      [
        :get,
        {
          path: "/work_submissions/1234",
          work_id: '1234',
          action: 'query_action',
          query_action_name: 'show'
        }
      ], [
        :get,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'query_action',
          query_action_name: 'edit'
        }
      ], [
        :post,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          command_action_name: 'edit'
        }
      ], [
        :patch,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          command_action_name: 'edit'
        }
      ], [
        :put,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          command_action_name: 'edit'
        }
      ], [
        :delete,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          command_action_name: 'edit'
        }
      ]
    ].each do |http_method, settings|
      it "will #{http_method.to_s.upcase} #{settings.fetch(:path)}" do
        expect(send(http_method, settings.fetch(:path))).
          to route_to(settings.except(:path).merge(controller: controller))
      end
    end
  end
end
