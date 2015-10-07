require 'active_model/validator'

# Responsible for validating netid
class NetIdValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super
    self.netid_remote_validator = options.fetch(:netid_remote_validator) { default_netid_remote_validator }
  end

  def default_netid_remote_validator
    Rails.application.config.default_netid_remote_validator
  end

  def validate_each(record, attribute, value)
    return true unless value.present?
    # TODO: validate netid is valid one through ldap
    record.errors.add(attribute, options[:message] || :invalid) unless netid_remote_validator.call(value)
  end

  private

  attr_accessor :netid_remote_validator
end
