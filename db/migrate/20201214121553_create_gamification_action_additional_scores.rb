class CreateGamificationActionAdditionalScores < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_action_additional_scores do |t|
      t.references :gamification_action, foreign_key: true, null: false, index: { name: "idx_gamification_additional_scores_on_gamification_action_id" }
      t.references :process, polymorphic: true, null: false, index: { name: "idx_gamification_additional_scores_on_process_type_process_id" }
      t.integer :additional_score, null: false

      t.timestamps
    end

    add_index :gamification_action_additional_scores, [:gamification_action_id, :process_type, :process_id], unique: true, name: "idx_gamification_additional_scores_on_action_and_process"

  end
end
