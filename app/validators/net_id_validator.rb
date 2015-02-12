# Responsible for validating netid
class NetIdValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super
    @netid_remote_validator = options.fetch(:netid_remote_validator) { default_netid_remote_validator }
  end

  attr_reader :netid_remote_validator
  private :netid_remote_validator

  def default_netid_remote_validator
    ->(_a_netid) { true }
  end

  def validate_each(record, attribute, value)
    return true unless value.present?
    # TODO: validate netid is valid one through ldap
    record.errors.add(attribute, options[:message] || :invalid) unless netid_remote_validator.call(value)
  end
end
