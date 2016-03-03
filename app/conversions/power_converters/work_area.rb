PowerConverter.define_conversion_for(:work_area) do |input|
  # TODO: Add the case for a Work, ProcessingEntity
  case input
  when Sipity::Models::WorkArea
    input
  when Sipity::Models::SubmissionWindow, Sipity::Models::Work
    input.work_area
  when Sipity::Models::Processing::Entity
    PowerConverter.convert(input.proxy_for, to: :work_area)
  when Sipity::Models::Processing::EntityActionRegister
    # This is not a good long term solution as it leverages the entity conversion which leverages the proxy for conversion.
    # But its a stop gap
    PowerConverter.convert(input.entity, to: :work_area)
  when Symbol, String
    Sipity::Models::WorkArea.find_by(name: input.to_s) || Sipity::Models::WorkArea.find_by(slug: input.to_s)
  end
end
