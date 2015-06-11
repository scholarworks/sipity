class DropTransientAnswerTable < ActiveRecord::Migration
  def change
    drop_table 'sipity_transient_answers'
  end
end
