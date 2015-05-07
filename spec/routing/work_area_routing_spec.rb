require 'spec_helper'

describe 'work area routing spec' do
  context 'sipity/controllers/work_areas' do
    let(:controller) { 'sipity/controllers/work_areas' }
    [
      [
        :get,
        { path: "/areas/my_slug", action: 'query_action', work_area_slug: 'my_slug', processing_action_name: 'show' }
      ], [
        :get,
        { path: "/areas/my_slug/do/fun_things", action: 'query_action', work_area_slug: 'my_slug', processing_action_name: 'fun_things' }
      ], [
        :post,
        { path: "/areas/my_slug/do/fun_things", action: 'command_action', work_area_slug: 'my_slug', processing_action_name: 'fun_things' }
      ], [
        :put,
        { path: "/areas/my_slug/do/fun_things", action: 'command_action', work_area_slug: 'my_slug', processing_action_name: 'fun_things' }
      ], [
        :patch,
        { path: "/areas/my_slug/do/fun_things", action: 'command_action', work_area_slug: 'my_slug', processing_action_name: 'fun_things' }
      ], [
        :delete,
        { path: "/areas/my_slug/do/fun_things", action: 'command_action', work_area_slug: 'my_slug', processing_action_name: 'fun_things' }
      ]
    ].each do |http_method, settings|
      it "will #{http_method.to_s.upcase} #{settings.fetch(:path)}" do
        expect(send(http_method, settings.fetch(:path))).
          to route_to(settings.except(:path).merge(controller: controller))
      end
    end
  end
end
