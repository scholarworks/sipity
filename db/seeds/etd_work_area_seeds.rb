Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: 'etd') do |work_area|
  Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(
    slug: 'start', work_area: work_area, open_for_starting_submissions_at: Date.new(2015,6,12).to_time.in_time_zone
  )
end
