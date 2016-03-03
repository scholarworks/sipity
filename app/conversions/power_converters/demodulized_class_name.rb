PowerConverter.define_conversion_for(:demodulized_class_name) do |input|
  case input
  when Symbol, String
    input.to_s.gsub(/\W+/, '_').classify
  when NilClass
    ''
  end
end
