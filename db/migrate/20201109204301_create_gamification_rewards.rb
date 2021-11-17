class CreateGamificationRewards < ActiveRecord::Migration[5.0]
  def change
    create_table :gamification_rewards do |t|
      t.integer :minimum_score
      t.references :gamification, foreign_key: true, null: false, index: true
      t.boolean :active
      t.boolean :request_to_administrators

      t.timestamps
    end
    create_table :gamification_reward_translations do |t|
      t.references :gamification_reward, index: { name: "idx_gamification_reward_translations_on_gamification_reward_id" }
      t.string     :locale
      t.string     :title
      t.text       :description
      t.timestamps
    end

    add_index :gamification_reward_translations, [:gamification_reward_id, :locale], unique: true, name: 'idx_gamification_reward_translations_on_reward_id_and_locale'
  end
end
