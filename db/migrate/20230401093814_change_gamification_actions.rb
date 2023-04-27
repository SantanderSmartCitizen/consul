class ChangeGamificationActions < ActiveRecord::Migration[5.0]
  def change
    remove_column :gamification_actions, :gamification_id, :integer
    add_column :gamification_actions, :locked, :boolean, default: false, null: false
  end
end
