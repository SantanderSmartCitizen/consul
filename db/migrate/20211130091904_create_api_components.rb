class CreateApiComponents < ActiveRecord::Migration[5.0]
  def change
    create_table :api_components do |t|
      t.string :name
      t.string :secret

      t.timestamps
    end
  end
end
