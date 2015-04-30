require 'spec_helper'

describe 'work area routing spec' do
  it "will route GET /areas/:work_area_slug" do
    expect(get: "/areas/my_slug").
      to route_to(controller: 'sipity/controllers/work_areas', action: 'show', work_area_slug: 'my_slug')
  end

  it "will route GET /areas/:work_area_slug/:submission_window_slug" do
    expect(get: "/areas/etd/start").to(
      route_to(
        controller: 'sipity/controllers/work_areas',
        action: 'submission_window',
        work_area_slug: 'etd',
        submission_window_slug: 'start'
      )
    )
  end
end
