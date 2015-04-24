module Sipity
  module Models
    # Responsible for giving a name to a group of people. This is not the role
    # nor responsibility that those people fill. It is an alias for a collection
    # of people.
    #
    # @see User
    class Group < ActiveRecord::Base
      self.table_name = 'sipity_groups'

      # Why are there validations here and not on other models? Because I'm
      # not intending to create a form to represent this object. If things get
      # complicated, then a form will happen.
      validates :name, presence: true, uniqueness: true

      has_many :group_memberships, dependent: :destroy
      has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
    end
  end
end
