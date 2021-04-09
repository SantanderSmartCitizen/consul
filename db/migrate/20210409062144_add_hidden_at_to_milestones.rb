class AddHiddenAtToMilestones < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :hidden_at, :datetime
    add_index :milestones, :hidden_at
  end
end
