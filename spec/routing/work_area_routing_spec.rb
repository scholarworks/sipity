require "rails_helper"

describe 'work area routing spec' do
  context 'sipity/controllers/work_areas' do
    let(:controller) { 'sipity/controllers/work_areas' }
    [
      [
        # Because of routing contraints this won't be found in the work areas
        :get,
        { path: "/areas/my_slug", controller: 'sipity/controllers/visitors', action: 'work_area', work_area_slug: 'my_slug' }
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
          to route_to({ controller: controller }.merge(settings.except(:path)))
      end
    end

    it 'will have a routable power conversion' do
      work_area = Sipity::Models::WorkArea.new(slug: 'wa-slug')
      root_path = PowerConverter.convert_to_processing_action_root_path(work_area)
      expect(get: File.join(root_path, 'funny_things')).to(
        route_to(
          controller: controller,
          action: 'query_action',
          processing_action_name: 'funny_things',
          work_area_slug: 'wa-slug'
        )
      )
    end
  end
end
