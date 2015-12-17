Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Hesburgh Library Project Proposals', slug: 'library-project') do |work_area|
  opening_at = Date.new(2015,12,17).to_date.in_time_zone
  Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(
    slug: 'proposals', work_area: work_area, open_for_starting_submissions_at: opening_at
  )
end
