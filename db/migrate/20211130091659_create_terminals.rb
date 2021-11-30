class CreateTerminals < ActiveRecord::Migration[5.0]
  def change
    create_table :terminals do |t|
      t.string :code
      t.string :service
      t.string :description
      t.string :location
      t.references :poll, foreign_key: true

      t.timestamps
    end
  end
end
