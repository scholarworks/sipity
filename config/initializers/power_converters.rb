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

PowerConverter.define_conversion_for(:demodulized_class_name) do |input|
  case input
  when Symbol, String
    input.to_s.downcase.gsub(/\W+/, '_').classify
  when NilClass
    ''
  end
end

PowerConverter.define_conversion_for(:work_type) do |input|
  case input
  when Symbol, String
    Sipity::Models::WorkType.find_by(name: input.to_s)
  when Sipity::Models::WorkType
    input
  end
end

PowerConverter.define_conversion_for(:work_area) do |input|
  # TODO: Add the case for a Work, ProcessingEntity
  case input
  when Sipity::Models::WorkArea
    input
  when Sipity::Models::SubmissionWindow
    input.work_area
  when Symbol, String
    Sipity::Models::WorkArea.find_by(name: input.to_s) || Sipity::Models::WorkArea.find_by(slug: input.to_s)
  end
end
