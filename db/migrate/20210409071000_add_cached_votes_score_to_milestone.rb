class AddCachedVotesScoreToMilestone < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :cached_votes_score, :integer, default: 0
    add_index :milestones, :cached_votes_score
  end
end
