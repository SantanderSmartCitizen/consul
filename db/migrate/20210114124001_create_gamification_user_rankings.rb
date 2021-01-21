class CreateGamificationUserRankings < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_user_rankings do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.references :gamification, foreign_key: true, index: true, null: false
      t.integer :score

      t.timestamps
    end

    add_index :gamification_user_rankings, [:user_id, :gamification_id], unique: true
  end
end
