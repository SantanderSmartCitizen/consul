class CreateGamifications < ActiveRecord::Migration[5.0]
  def change
    create_table :gamifications do |t|
   	  t.string :key
      t.boolean :locked, default: false
      t.timestamps
    end

    create_table :gamification_translations do |t|
      t.references :gamification
      t.string     :locale
      t.string     :title
      t.text       :description
      t.timestamps
    end

    add_index :gamifications, [:key], :unique => true
    add_index :gamification_translations, [:gamification_id, :locale], :unique => true
  end
end
