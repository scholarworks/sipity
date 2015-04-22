require 'spec_helper'

describe 'work area routing spec' do
  it "will route GET /work_areas/:work_area_slug" do
    expect(get: "/work_areas/my_slug").
      to route_to(controller: 'sipity/controllers/work_areas', action: 'show', work_area_slug: 'my_slug')
  end
end
