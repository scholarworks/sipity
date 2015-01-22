# Every application needs users. Right? This is that class.
class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, if:  :new_record?

  def set_default_role
    self.role ||= :user
  end

  devise :cas_authenticatable, :trackable

  has_many :permissions, as: :actor, dependent: :destroy, class_name: 'Sipity::Models::Permission'
end
