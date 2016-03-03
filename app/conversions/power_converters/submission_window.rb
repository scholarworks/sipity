PowerConverter.define_conversion_for(:submission_window) do |input, work_area|
  case input
  when Sipity::Models::Work
    input.submission_window
  when Sipity::Models::SubmissionWindow
    if work_area
      input if input.work_area_id == work_area.id
    else
      input
    end
  end
end
