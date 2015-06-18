slug = Sipity::DataGenerators::WorkAreas::SelfDepositGenerator::SLUG

Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Self-Deposit into CurateND', slug: slug) do |work_area|
  Sipity::DataGenerators::FindOrCreateSubmissionWindow.call(slug: 'start', work_area: work_area)
end
