PowerConverter.define_conversion_for(:access_path) do |input|
  case input
  when Sipity::Models::WorkArea
    "/areas/#{input.slug}"
  when Sipity::Models::SubmissionWindow
    "/areas/#{input.work_area_slug}/#{input.slug}"
  when Sipity::Models::Work
    "/work_submissions/#{input.id}"
  end
end
