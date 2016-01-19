class RenameSpecificRolesToVerbs < ActiveRecord::Migration
  def self.up
    [
      ["advisor", "advising"],
      ["batch_ingestor", "batch_ingesting"],
      ["cataloger", "cataloging"],
      ["creating_user", "creating_user"],
      ["data_observer", "data_observing"],
      ["etd_reviewer", "etd_reviewing"],
      ["submission_window_viewer", "submission_window_viewing"],
      ["ulra_reviewer", "ulra_reviewing"],
      ["work_area_manager", "work_area_managing"],
      ["work_area_viewer", "work_area_viewing"],
      ["work_submitter", "work_submitting"]
    ].each do |before, after|
      old_role = Sipity::Models::Role.find_by(name: before)
      next if old_role.nil?
      next if Sipity::Models::Role.find_by(name: after)
      role.update!(name: after)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
