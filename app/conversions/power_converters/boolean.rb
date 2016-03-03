PowerConverter.define_conversion_for(:boolean) do |input|
  case input
  when false, 0, '0', /\A(false|no)\Z/i, nil then false
  when String
    input.strip.blank? ? nil : true
  else
    true
  end
end
