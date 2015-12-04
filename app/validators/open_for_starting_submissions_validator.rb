require 'active_model/validator'

# Responsible for validating that a submission window is open for starting submissions
class OpenForStartingSubmissionsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    as_of = Time.zone.now
    if value.open_for_starting_submissions_at.nil?
      record.errors.add(attribute, options[:message] || :invalid)
      return false
    end
    if value.open_for_starting_submissions_at > as_of
      record.errors.add(attribute, options[:message] || :invalid)
      return false
    end
    return true if value.closed_for_starting_submissions_at.nil?
    if value.closed_for_starting_submissions_at < as_of
      record.errors.add(attribute, options[:message] || :invalid)
      return false
    end
    return true
  end
end
