class CreateGamificationAdditionalScores < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_additional_scores do |t|
      t.references :gamification_action, foreign_key: true, null: false
      t.integer :process_id, null: false
      t.integer :additional_score, null: false

      t.timestamps
    end
  end
end
