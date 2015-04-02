require 'devise/strategies/cas_authenticatable_with_service_agreement'

# Every application needs users. Right? This is that class.
class User < ActiveRecord::Base
  devise :cas_authenticatable, :trackable

  has_many :group_memberships, dependent: :destroy, class_name: 'Sipity::Models::GroupMembership'
  has_many :group, through: :group_memberships, class_name: 'Sipity::Models::Group'
  has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
  has_many :event_logs, class_name: 'Sipity::Models::EventLog'

  # I'm using a callback because Devise CAS authentication is creating the
  # record.
  before_save :set_notre_dame_specific_email, if: :new_record?

  # Because of the unique constraint on User#email, when we receive an empty
  # email for user (e.g. the user form that was filled out had blank spaces for
  # the given email), blank that out.
  def email=(value)
    if value.present?
      super(value)
    else
      super(nil)
    end
  end

  def to_s
    # HACK: Name is better, but in some cases this may not be assigned.
    # So defer to username. See issues#436
    name || username
  end

  private

  def set_notre_dame_specific_email
    self.email ||= "#{username}@nd.edu"
  end
end
