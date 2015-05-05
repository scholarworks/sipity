require 'spec_helper'

describe 'work area routing spec' do
  context 'sipity/controllers/work_areas' do
    let(:controller) { 'sipity/controllers/work_areas' }
    [
      [
        :get,
        { path: "/areas/my_slug", action: 'show', work_area_slug: 'my_slug' }
      ], [
        :get,
        { path: "/areas/my_slug/edit", action: 'edit', work_area_slug: 'my_slug' }
      ], [
        :get,
        { path: "/areas/my_slug/do/edit", action: 'edit', work_area_slug: 'my_slug' }
      ], [
        :get,
        { path: "/areas/my_slug/do/fun_things", action: 'query_action', work_area_slug: 'my_slug', query_action_name: 'fun_things' }
      ], [
        :put,
        { path: "/areas/my_slug", action: 'update', work_area_slug: 'my_slug' }
      ], [
        :put,
        { path: "/areas/my_slug/edit", action: 'update', work_area_slug: 'my_slug' }
      ], [
        :put,
        { path: "/areas/my_slug/do/edit", action: 'update', work_area_slug: 'my_slug' }
      ], [
        :post,
        { path: "/areas/my_slug/do/fun_things", action: 'command_action', work_area_slug: 'my_slug', command_action_name: 'fun_things' }
      ]
    ].each do |http_method, settings|
      it "will #{http_method.to_s.upcase} #{settings.fetch(:path)}" do
        expect(send(http_method, settings.fetch(:path))).
          to route_to(settings.except(:path).merge(controller: controller))
      end
    end
  end
end
