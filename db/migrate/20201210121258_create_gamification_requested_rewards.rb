class CreateGamificationRequestedRewards < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_requested_rewards do |t|
      t.references :gamification_reward, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :administrator, foreign_key: {to_table: :users}
      t.timestamp :executed_at

      t.timestamps
    end
  end
end
