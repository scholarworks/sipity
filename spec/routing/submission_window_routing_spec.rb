require "rails_helper"

describe 'work area routing spec', type: :routing do
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

    it 'will have a routable power conversion' do
      submission_window = Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug'))
      root_path = PowerConverter.convert_to_processing_action_root_path(submission_window)
      expect(get: File.join(root_path, 'funny_things')).to(
        route_to(
          controller: controller,
          action: 'query_action',
          processing_action_name: 'funny_things',
          work_area_slug: 'wa-slug',
          submission_window_slug: 'sw-slug'
        )
      )
    end
  end
end
