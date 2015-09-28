class AddIdentifierIdToCollaborator < ActiveRecord::Migration
  def change
    # At present I can't decide which of these I'd like to keep
    add_column :sipity_collaborators, :strategy, :string, index: true
    add_column :sipity_collaborators, :identifying_value, :string, index: true
    add_column :sipity_collaborators, :identifier_id, :string, index: true
  end
end
