PowerConverter.define_conversion_for(:safe_for_method_name) do |input|
  case input
  when Symbol, String
    input.to_s.gsub(/\W+/, '_').underscore if input.present?
  end
end
