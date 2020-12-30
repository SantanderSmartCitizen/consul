class CreateGamificationUserActions < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_user_actions do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.references :gamification_action, foreign_key: true, index: true, null: false
      t.references :process, polymorphic: true, index: { name: "idx_gamification_user_actions_on_process_type_process_id" }

      t.timestamps
    end
  end
end
