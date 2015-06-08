# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
user = User.find_or_create_by!(username: ENV['USER'])

graduate_school_reviewers = Sipity::DataGenerators::WorkTypes::EtdGenerator::GRADUATE_SCHOOL_REVIEWERS
$stdout.puts "Finding or creating group for '#{graduate_school_reviewers}'"
graduate_school = Sipity::Models::Group.find_or_create_by!(name: graduate_school_reviewers)

$stdout.puts "Associating #{user.username} with #{graduate_school.name}"
graduate_school.group_memberships.find_or_create_by(user: user)
