Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Undergraduate Library Research Awards', slug: 'ulra') do |work_area|
  Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(slug: '2016', work_area: work_area)
end
