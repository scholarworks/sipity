class AddRepresentativeToAttachment < ActiveRecord::Migration
  def change
    add_column :sipity_attachments, :mark_as_representative, :boolean, default: false
  end
end
