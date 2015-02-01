# Every application needs users. Right? This is that class.
class User < ActiveRecord::Base
  devise :cas_authenticatable, :trackable

  has_many :permissions, as: :actor, dependent: :destroy, class_name: 'Sipity::Models::Permission'
end
