Sipity::Models::WorkType.valid_names.each do |work_type_name|
  Sipity::Models::WorkType.find_or_create_by!(name: work_type_name)
end
