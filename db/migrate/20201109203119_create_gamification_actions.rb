class CreateGamificationActions < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_actions do |t|
      t.string :key
      t.integer :score
      t.references :gamification, foreign_key: true

      t.timestamps
    end

    create_table :gamification_action_translations do |t|
      t.references :gamification_action, index: { name: "idx_gamification_action_translations_on_gamification_action_id" }
      t.string     :locale
      t.string     :title
      t.text       :description
      t.timestamps
    end

    add_index :gamification_actions, [:key, :gamification_id], unique: true
    add_index :gamification_action_translations, [:gamification_action_id, :locale], unique: true, name: "idx_gamification_action_translations_on_action_id_and_locale"
  end
end
