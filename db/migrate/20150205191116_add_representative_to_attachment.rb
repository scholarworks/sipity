class AddRepresentativeToAttachment < ActiveRecord::Migration
  def change
    add_column :sipity_attachments, :is_representative_file, :boolean, default: false
  end
end
