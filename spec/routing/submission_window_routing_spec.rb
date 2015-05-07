require 'spec_helper'

describe 'work area routing spec' do
  context 'sipity/controllers/submission_windows' do
    let(:controller) { 'sipity/controllers/submission_windows' }
    [
      [
        :get,
        {
          path: "/areas/area-slug/start",
          action: 'query_action',
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          processing_action_name: 'show'
        }
      ], [
        :get,
        {
          path: "/areas/area-slug/start/do/edit",
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          action: 'query_action',
          processing_action_name: 'edit'
        }
      ], [
        :post,
        {
          path: "/areas/area-slug/start/do/edit",
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :patch,
        {
          path: "/areas/area-slug/start/do/edit",
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :put,
        {
          path: "/areas/area-slug/start/do/edit",
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :delete,
        {
          path: "/areas/area-slug/start/do/edit",
          work_area_slug: 'area-slug',
          submission_window_slug: 'start',
          action: 'command_action',
          processing_action_name: 'edit'
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
