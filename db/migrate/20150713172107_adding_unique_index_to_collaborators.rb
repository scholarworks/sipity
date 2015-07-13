class AddingUniqueIndexToCollaborators < ActiveRecord::Migration
  def change
    Sipity::Models::Collaborator.connection.execute("UPDATE `sipity_collaborators` SET email = NULL WHERE email = '';")
    Sipity::Models::Collaborator.connection.execute("UPDATE `sipity_collaborators` SET netid = NULL WHERE netid = '';")
    add_index :sipity_collaborators, [:work_id, :email], unique: true
    add_index :sipity_collaborators, [:work_id, :netid], unique: true
  end
end
