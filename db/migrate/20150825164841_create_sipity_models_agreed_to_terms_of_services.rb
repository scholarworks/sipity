class CreateSipityModelsAgreedToTermsOfServices < ActiveRecord::Migration
  def change
    create_table :sipity_agreed_to_terms_of_services, id: false do |t|
      t.string :identifier_id, null: false
      t.datetime :agreed_at, null: false

      t.timestamps null: false
    end

    add_index :sipity_agreed_to_terms_of_services, :identifier_id, unique: true
  end
end
