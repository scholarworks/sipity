PowerConverter.define_conversion_for(:processing_comment) do |input|
  case input
  when Sipity::Models::Processing::Comment
    input
  when Sipity::Models::Processing::EntityActionRegister
    PowerConverter.convert_to_processing_comment(input.subject)
  end
end
