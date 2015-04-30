Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: 'etd') do |work_area|
  Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(slug: 'start', work_area: work_area)
end
