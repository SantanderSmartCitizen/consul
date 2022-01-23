class CreateTerminals < ActiveRecord::Migration[5.0]
  def change
    create_table :terminals do |t|
      t.string :code
      t.string :serial_number
      t.string :name
      t.string :description
      t.string :service
      t.string :location
      t.references :poll, foreign_key: true

      t.timestamps
    end
  end
end
