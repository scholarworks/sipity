class UpdateFacultyAttachmentPredicate < ActiveRecord::Migration
  def self.up
    Sipity::Models::AdditionalAttribute.
      where(key: 'faculty_comments_attachment').
      update_all(key: 'faculty_letter_of_recommendation')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
