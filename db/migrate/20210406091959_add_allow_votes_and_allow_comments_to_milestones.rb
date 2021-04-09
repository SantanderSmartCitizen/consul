class AddAllowVotesAndAllowCommentsToMilestones < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :allow_votes, :boolean, default: false
    add_column :milestones, :allow_comments, :boolean, default: false
  end
end
