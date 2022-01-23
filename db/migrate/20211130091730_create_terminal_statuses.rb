class CreateTerminalStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :terminal_statuses do |t|
      t.references :terminal, foreign_key: true
      t.string :location
      t.boolean :switched_on
      t.float :cpu
      t.float :ram
      t.float :storage
      t.float :battery
      t.integer :battery_saver
      t.text :msg

      t.timestamps
    end
  end
end
