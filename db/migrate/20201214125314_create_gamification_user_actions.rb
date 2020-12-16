class CreateGamificationUserActions < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_user_actions do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.references :gamification_action, foreign_key: true, index: true, null: false
      t.integer :action_score, null: false
      t.integer :process_id
      t.integer :additional_score

      t.timestamps
    end
  end
end
