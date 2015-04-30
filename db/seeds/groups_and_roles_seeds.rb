$stdout.puts 'Creating Groups...'
graduate_school_reviewers = Sipity::DataGenerators::Etd::SubmissionWindowProcessingGenerator::GRADUATE_SCHOOL_REVIEWERS
Sipity::Conversions::ConvertToProcessingActor.call(
  Sipity::Models::Group.find_or_create_by!(name: graduate_school_reviewers)
)

$stdout.puts 'Add existing users to All Registered Users Groups...'
Sipity::Models::Group.find_or_create_by!(name: Sipity::Models::Group::ALL_REGISTERED_USERS)
#add existing users to that group (unless they are already there)
User.find_each do |user|
  puts "User: #{user.inspect}"
  Sipity::DataGenerators::OnUserCreate.call(user)
end

$stdout.puts 'Creating Valid Roles...'
Sipity::Models::Role.valid_names.each do |name|
  Sipity::Models::Role.find_or_create_by!(name: name)
end
