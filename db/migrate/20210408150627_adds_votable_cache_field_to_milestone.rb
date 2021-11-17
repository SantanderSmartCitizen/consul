class AddsVotableCacheFieldToMilestone < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :cached_votes_total, :integer, default: 0
    add_column :milestones, :cached_votes_up, :integer, default: 0
    add_column :milestones, :cached_votes_down, :integer, default: 0

    add_index  :milestones, :cached_votes_total
    add_index  :milestones, :cached_votes_up
    add_index  :milestones, :cached_votes_down
  end
end
