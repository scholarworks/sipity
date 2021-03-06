# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
user = User.find_or_create_by!(username: ENV['USER'])

graduate_school_reviewers = Sipity::DataGenerators::WorkTypes::EtdGenerator::GRADUATE_SCHOOL_REVIEWERS
$stdout.puts "Finding or creating group for '#{graduate_school_reviewers}'"
graduate_school = Sipity::Models::Group.find_or_create_by!(name: graduate_school_reviewers)

batch_ingestor_name = Sipity::Models::Group::BATCH_INGESTORS
$stdout.puts "Finding or batch ingestors for '#{batch_ingestor_name}'"
batch_ingestor = Sipity::Models::Group.find_or_create_by!(name: batch_ingestor_name)
batch_ingestor.update!(api_key: Figaro.env.sipity_access_key_for_batch_ingester!)

$stdout.puts "Finding or batch ingestors for '#{Sipity::Models::Group::ETD_INTEGRATORS}'"
integrator = Sipity::Models::Group.find_or_create_by!(name: Sipity::Models::Group::ETD_INTEGRATORS)
integrator.update!(api_key: Figaro.env.sipity_access_key_for_etd_integrators!)

$stdout.puts "Associating #{user.username} with #{graduate_school.name}"
graduate_school.group_memberships.find_or_create_by(user: user)

catalogers = Sipity::DataGenerators::WorkTypes::EtdGenerator::CATALOGERS
$stdout.puts "Finding or creating group for '#{catalogers}'"
cataloging = Sipity::Models::Group.find_or_create_by!(name: catalogers)

$stdout.puts "Associating #{user.username} with #{cataloging.name}"
cataloging.group_memberships.find_or_create_by(user: user)

$stdout.puts "Creating User batch_ingestor"
batch_ingestor = User.find_or_create_by!(username: "batch_ingesting")

$stdout.puts "Associating batch_ingestor with #{batch_ingestor.name}"
batch_ingestor.group_memberships.find_or_create_by(user: batch_ingestor)

ulra_review_committee_group_name = Sipity::DataGenerators::WorkTypes::UlraGenerator::ULRA_REVIEW_COMMITTEE_GROUP_NAME
$stdout.puts "Finding or creating group for '#{ulra_review_committee_group_name}'"
ulra_review_committee_group = Sipity::Models::Group.find_or_create_by!(name: ulra_review_committee_group_name)

$stdout.puts "Associating #{user.name} with #{ulra_review_committee_group.name}"
ulra_review_committee_group.group_memberships.find_or_create_by(user: batch_ingestor)

ulra_data_remediators = 'ULRA Data Remediators'
$stdout.puts "Finding or creating group for '#{ulra_data_remediators}'"
ulra_data_remediator_group = Sipity::Models::Group.find_or_create_by!(name: ulra_data_remediators)

$stdout.puts "Associating #{user.name} with #{ulra_data_remediator_group.name}"
ulra_data_remediator_group.group_memberships.find_or_create_by(user: user)
