require 'power_converter'
require 'cogitate/interfaces'
require 'cogitate/client'
require 'cogitate/models/identifier'
require 'cogitate/models/agent'

PowerConverter.define_conversion_for(:access_path) do |input|
  case input
  when Sipity::Models::WorkArea
    "/areas/#{input.slug}"
  when Sipity::Models::SubmissionWindow
    "/areas/#{input.work_area_slug}/#{input.slug}"
  when Sipity::Models::Work
    "/work_submissions/#{input.id}"
  end
end

PowerConverter.define_conversion_for(:access_url) do |input|
  case input
  when Sipity::Models::Attachment
    input.file_url
  else
    File.join(Figaro.env.url_host, PowerConverter.convert_to_access_path(input))
  end
end

PowerConverter.define_conversion_for(:authentication_agent) do |input|
  input if Contract.valid?(input, Sipity::Interfaces::AuthenticationAgentInterface)
end

PowerConverter.define_conversion_for(:boolean) do |input|
  case input
  when false, 0, '0', 'false', 'no', nil then false
  else
    true
  end
end

PowerConverter.define_conversion_for(:demodulized_class_name) do |input|
  case input
  when Symbol, String
    input.to_s.gsub(/\W+/, '_').classify
  when NilClass
    ''
  end
end

PowerConverter.define_conversion_for(:file_system_safe_file_name) do |input|
  case input
  when Symbol, String, NilClass
    input.to_s.gsub(/\W+/, '_').underscore.downcase
  end
end

PowerConverter.define_conversion_for(:identifiable_agent) do |input|
  if Contract.valid?(input, Sipity::Interfaces::IdentifiableAgentInterface)
    input
  elsif input.is_a?(String)
    Sipity::Models::IdentifiableAgent.new_for_identifier_id(identifier_id: PowerConverter.convert(input, to: :identifier_id))
  end
end

PowerConverter.define_conversion_for(:identifier_id) do |input|
  case input
  when String
    result = Cogitate::Client.extract_strategy_and_identifying_value(input)
    # Because we have an array of two elements from the parsed value
    result.count == 2 ? input : nil
  when Cogitate::Models::Identifier, Cogitate::Models::Agent
    input.id
  when Sipity::Models::Collaborator
    if input.identifier_id.present?
      input.identifier_id
    elsif input.email.present?
      Cogitate::Client.encoded_identifier_for(strategy: 'email', identifying_value: input.email)
    end
  end
end

PowerConverter.define_conversion_for(:processing_comment) do |input|
  case input
  when Sipity::Models::Processing::Comment
    input
  when Sipity::Models::Processing::EntityActionRegister
    PowerConverter.convert_to_processing_comment(input.subject)
  end
end

PowerConverter.define_conversion_for(:processing_action_root_path) do |input|
  File.join(PowerConverter.convert_to_access_path(input), 'do')
end

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

PowerConverter.define_conversion_for(:role_name) do |input|
  case input
  when Sipity::Models::Role
    input.name
  when String, Symbol then
    begin
    # Leveraging Role's enum(:name) behavior for enforcement
      Sipity::Models::Role.new(name: input.to_s).name if input.present?
    rescue ArgumentError
      nil
    end
  end
end

PowerConverter.define_conversion_for(:safe_for_method_name) do |input|
  case input
  when NilClass
    nil
  when Symbol, String
    if input.present?
      input.to_s.gsub(/\W+/, '_').underscore
    else
      nil
    end
  end
end

PowerConverter.define_conversion_for(:strategy_state) do |input, strategy|
  case input
  when Sipity::Models::Processing::StrategyState
    input
  when Symbol, String
    Sipity::Models::Processing::StrategyState.where(strategy_id: strategy.id, name: input).first
  end
end

# Slugs should be human and machine readable
#
# > We recommend that you use hyphens (-) instead of underscores (_) in your
# > URLs.
#
# https://support.google.com/webmasters/answer/76329?hl=en
PowerConverter.define_conversion_for(:slug) do |input|
  case input
  when Symbol, String, NilClass
    input.to_s.gsub(/\W+/, '_').underscore.gsub(/_+/, '-').downcase
  end
end

PowerConverter.define_conversion_for(:submission_window) do |input, work_area|
  case input
  when Sipity::Models::Work
    input.submission_window
  when Sipity::Models::SubmissionWindow
    if work_area
      input if input.work_area_id == work_area.id
    else
      input
    end
  end
end

PowerConverter.define_conversion_for(:work_area) do |input|
  # TODO: Add the case for a Work, ProcessingEntity
  case input
  when Sipity::Models::WorkArea
    input
  when Sipity::Models::SubmissionWindow, Sipity::Models::Work
    input.work_area
  when Sipity::Models::Processing::Entity
    PowerConverter.convert(input.proxy_for, to: :work_area)
  when Symbol, String
    Sipity::Models::WorkArea.find_by(name: input.to_s) || Sipity::Models::WorkArea.find_by(slug: input.to_s)
  end
end

PowerConverter.define_conversion_for(:work_type) do |input|
  case input
  when Symbol, String
    begin
      Sipity::Models::WorkType.find_or_create_by!(name: input.to_s)
    rescue ArgumentError
      nil
    end
  when Sipity::Models::WorkType
    input
  end
end
