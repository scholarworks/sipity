$stdout.puts 'Creating Groups...'
GRADUATE_SCHOOL_REVIEWERS = 'Graduate School Reviewers' unless defined?(GRADUATE_SCHOOL_REVIEWERS)
Sipity::Conversions::ConvertToProcessingActor.call(
  Sipity::Models::Group.find_or_create_by!(name: GRADUATE_SCHOOL_REVIEWERS)
)

$stdout.puts 'Creating Valid Roles...'
Sipity::Models::Role.valid_names.each do |name|
  Sipity::Models::Role.find_or_create_by!(name: name)
end
