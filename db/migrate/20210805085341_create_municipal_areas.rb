class CreateMunicipalAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :municipal_areas do |t|
    end

    create_table :municipal_area_translations do |t|
      t.references :municipal_area
      t.string     :locale
      t.string     :title
      t.timestamps
    end

    add_index :municipal_area_translations, [:municipal_area_id, :locale], :unique => true, name: "idx_municipal_area_translations_on_municipal_area_id_and_locale"
  end
end