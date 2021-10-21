class CreateHeaderSlides < ActiveRecord::Migration[5.0]
  def change
    create_table :header_slides do |t|
      t.string :page
	  t.timestamps
    end

    create_table :header_slide_translations do |t|
      t.references :header_slide
      t.string     :locale
      t.string     :title
      t.timestamps
    end
  end
end
