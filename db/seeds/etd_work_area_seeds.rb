Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: 'etd') do |work_area|
  path = Rails.root.join('app/data_generators/sipity/data_generators/submission_windows/etd_submission_windows.config.json')
  Sipity::DataGenerators::SubmissionWindowGenerator.call(work_area: work_area, path: path)
end
