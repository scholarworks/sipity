require 'power_converter'

PowerConverter.define_conversion_for(:boolean) do |input|
  case input
  when false, 0, '0', 'false', 'no', nil then false
  else
    true
  end
end

PowerConverter.define_conversion_for(:strategy_state) do |input, strategy|
  case input
  when Sipity::Models::Processing::StrategyState
    input
  when Symbol, String
    Sipity::Models::Processing::StrategyState.where(strategy_id: strategy.id, name: input).first
  end
end

PowerConverter.define_conversion_for(:slug) do |input|
  case input
  when Symbol, String, NilClass
    input.to_s.gsub(/\W+/, '_').underscore.gsub(/_+/, '-').downcase
  end
end

PowerConverter.define_alias(:file_system_safe_file_name, is_alias_of: :slug)

PowerConverter.define_conversion_for(:safe_for_method_name) do |input|
  case input
  when NilClass
    nil
  when Symbol, String
    if input.present?
      input.to_s.gsub(/\W+/, '_').underscore
    else
      nil
    end
  end
end

PowerConverter.define_conversion_for(:demodulized_class_name) do |input|
  case input
  when Symbol, String
    input.to_s.gsub(/\W+/, '_').classify
  when NilClass
    ''
  end
end

PowerConverter.define_conversion_for(:work_type) do |input|
  case input
  when Symbol, String
    begin
      Sipity::Models::WorkType.find_or_create_by!(name: input.to_s)
    rescue ArgumentError
      nil
    end
  when Sipity::Models::WorkType
    input
  end
end

PowerConverter.define_conversion_for(:work_area) do |input|
  # TODO: Add the case for a Work, ProcessingEntity
  case input
  when Sipity::Models::WorkArea
    input
  when Sipity::Models::SubmissionWindow, Sipity::Models::Work
    input.work_area
  when Symbol, String
    Sipity::Models::WorkArea.find_by(name: input.to_s) || Sipity::Models::WorkArea.find_by(slug: input.to_s)
  end
end

PowerConverter.define_conversion_for(:submission_window) do |input, work_area|
  case input
  when Sipity::Models::Work
    input.submission_window
  when Sipity::Models::SubmissionWindow
    input if input.work_area_id == work_area.id
  end
end