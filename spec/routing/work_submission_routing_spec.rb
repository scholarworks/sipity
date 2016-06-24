require "rails_helper"

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
          processing_action_name: 'show'
        }
      ], [
        :get,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'query_action',
          processing_action_name: 'edit'
        }
      ], [
        :post,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :patch,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :put,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :delete,
        {
          path: "/work_submissions/1234/do/edit",
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'edit'
        }
      ], [
        :post,
        {
          path: "/work_submissions/1234/callback/a_callback",
          controller: 'sipity/controllers/work_submission_callbacks',
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'a_callback'
        }
      ], [
        :patch,
        {
          path: "/work_submissions/1234/callback/a_callback",
          controller: 'sipity/controllers/work_submission_callbacks',
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'a_callback'
        }
      ], [
        :put,
        {
          path: "/work_submissions/1234/callback/a_callback",
          controller: 'sipity/controllers/work_submission_callbacks',
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'a_callback'
        }
      ], [
        :delete,
        {
          path: "/work_submissions/1234/callback/a_callback",
          controller: 'sipity/controllers/work_submission_callbacks',
          work_id: '1234',
          action: 'command_action',
          processing_action_name: 'a_callback'
        }
      ]
    ].each do |http_method, settings|
      it "will #{http_method.to_s.upcase} #{settings.fetch(:path)}" do
        expect(send(http_method, settings.fetch(:path))).to route_to({ controller: controller }.merge(settings.except(:path)))
      end
    end

    it 'will have a routable power conversion' do
      work = Sipity::Models::Work.new(id: 'work-id')
      root_path = PowerConverter.convert_to_processing_action_root_path(work)
      expect(get: File.join(root_path, 'funny_things')).to(
        route_to(
          controller: controller,
          action: 'query_action',
          processing_action_name: 'funny_things',
          work_id: 'work-id'
        )
      )
    end

    include Rails.application.routes.url_helpers
    it 'will preserve #work_path' do
      expect(work_path('1')).to eq('/works/1')
    end

    it 'will preserve #work_comments_path' do
      expect(work_comments_path(work_id: '1')).to eq('/work_submissions/1/comments')
    end
  end
end
