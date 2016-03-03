PowerConverter.define_conversion_for(:file_system_safe_file_name) do |input|
  case input
  when Symbol, String, NilClass
    input.to_s.gsub(/\W+/, '_').underscore.downcase
  end
end
