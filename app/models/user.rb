# Every application needs users. Right? This is that class.
class User < ActiveRecord::Base
  devise :cas_authenticatable, :trackable

  has_many :permissions, as: :actor, dependent: :destroy, class_name: 'Sipity::Models::Permission'
  has_many :group_memberships, dependent: :destroy, class_name: 'Sipity::Models::GroupMembership'
  has_many :group, through: :group_memberships, class_name: 'Sipity::Models::Group'
  has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
end
