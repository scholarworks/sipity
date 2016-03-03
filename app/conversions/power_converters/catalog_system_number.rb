PowerConverter.define_conversion_for(:catalog_system_number) do |input|
  case input
  when Float
    nil
  when Numeric
    format("%#9.09d", Integer(input))
  else
    begin
      format("%#9.09d", Integer(input, 10))
    rescue ArgumentError, TypeError
      nil
    end
  end
end
