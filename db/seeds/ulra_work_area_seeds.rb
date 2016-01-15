Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Undergraduate Library Research Awards', slug: 'ulra') do |work_area|
  path = Rails.root.join("app/data_generators/sipity/data_generators/submission_windows/ulra_submission_windows.config.json")
  Sipity::DataGenerators::SubmissionWindowGenerator.call(work_area: work_area, path: path)
end
