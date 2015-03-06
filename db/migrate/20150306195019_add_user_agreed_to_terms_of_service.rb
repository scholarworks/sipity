class AddUserAgreedToTermsOfService < ActiveRecord::Migration
  def change
    add_column :users, :agree_to_terms_of_service, :boolean, default: false
    add_index :users, :agree_to_terms_of_service
  end
end
