class CreateGamificationActions < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_actions do |t|
      t.string :key, null: false
      t.integer :score
      t.references :gamification, foreign_key: true, null: false, index: true
      t.string :process_type
      t.string :operation

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
    add_index :gamification_actions, [:gamification_id, :process_type, :operation], unique: true, where: "process_type IS NOT NULL and process_type <> '' and operation IS NOT NULL and operation <> ''", name: "idx_gamification_internal_actions"
    add_index :gamification_action_translations, [:gamification_action_id, :locale], unique: true, name: "idx_gamification_action_translations_on_action_id_and_locale"
  end
end
