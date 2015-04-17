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
    input.to_s.gsub(/\W+/, '-').downcase
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