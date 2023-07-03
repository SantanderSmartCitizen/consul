class CreateGamificationActionGames < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_action_games do |t|
      t.references :gamification_action, foreign_key: true, index: true, null: false
      t.references :gamification, foreign_key: true, index: true, null: false
      t.timestamps
    end
  end
end
