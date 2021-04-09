class AddCommentsCountToMilestone < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :comments_count, :integer, default: 0
  end
end
