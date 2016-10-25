PowerConverter.define_conversion_for(:processing_comment) do |input|
  case input
  when Sipity::Models::Processing::Comment
    input
  when Sipity::Models::Processing::EntityActionRegister
    PowerConverter.convert(input.subject, to: :processing_comment)
  end
end
