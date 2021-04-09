class AddAuthorIdToMilestone < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :author_id, :integer
  end
end
