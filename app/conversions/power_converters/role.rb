PowerConverter.define_conversion_for(:role) do |input|
  case input
  when Sipity::Models::Role
    input
  when String, Symbol then
    begin
      Sipity::Models::Role.find_or_create_by!(name: input)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError
      nil
    end
  end
end
