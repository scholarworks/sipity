require 'spec_helper'

describe 'work area routing spec' do
  it "will route GET /areas/:work_area_slug" do
    expect(get: "/areas/my_slug").
      to route_to(controller: 'sipity/controllers/work_areas', action: 'show', work_area_slug: 'my_slug')
  end
end
