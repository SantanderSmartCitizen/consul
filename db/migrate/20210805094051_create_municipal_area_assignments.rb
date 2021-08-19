class CreateMunicipalAreaAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :municipal_area_assignments do |t|
   	  t.references :municipal_area, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_index :municipal_area_assignments, [:municipal_area_id, :user_id], :unique => true, name: "idx_municipal_area_assignments_on_municipal_area_id_and_user_id"
  end
end
