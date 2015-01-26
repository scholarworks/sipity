require 'spec_helper'

describe 'work flow routing spec' do
  let(:work_id) { "12" }
  context 'enrichment routes' do
    ['attach', 'describe'].each do |enrichment_type|
      it "will route GET /works/:work_id/#{enrichment_type}" do
        expect(get: "/works/#{work_id}/#{enrichment_type}").
          to route_to(controller: 'sipity/controllers/work_enrichments', action: 'edit', work_id: work_id, enrichment_type: enrichment_type)
      end

      it "will route POST /works/:work_id/#{enrichment_type}" do
        expect(post: "/works/#{work_id}/#{enrichment_type}").
        to route_to(
          controller: 'sipity/controllers/work_enrichments', action: 'update', work_id: work_id, enrichment_type: enrichment_type
        )
      end

      it "will generate a path via an enrich_work_path(work_id, '#{enrichment_type}')" do
        expect(enrich_work_path(work_id, enrichment_type))
      end
    end

    it 'will NOT route for GET with an invalid enrichment_type' do
      expect(get: "/works/#{work_id}/__undefined__").to_not be_routable
    end

    it 'will NOT route for POST with an invalid enrichment_type' do
      expect(post: "/works/#{work_id}/__undefined__").to_not be_routable
    end
  end

  context 'event request routes' do
    let(:event_name) { 'do_it' }
    it 'will route GET /works/:work_id/request/:event_name' do
      expect(get: "/works/#{work_id}/request/#{event_name}").
        to route_to(controller: 'sipity/controllers/work_event_requests', action: 'new', work_id: work_id, event_name: event_name)
    end

    it 'will route POST /works/:work_id/request/:event_name' do
      expect(post: "/works/#{work_id}/request/#{event_name}").
        to route_to(controller: 'sipity/controllers/work_event_requests', action: 'create', work_id: work_id, event_name: event_name)
    end
  end
end
