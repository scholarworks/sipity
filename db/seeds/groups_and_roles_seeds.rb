$stdout.puts 'Creating Valid Roles...'
Sipity::Models::Role.valid_names.each do |name|
  Sipity::Models::Role.find_or_create_by!(name: name)
end
