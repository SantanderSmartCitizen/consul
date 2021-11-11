class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end

    create_table :event_translations do |t|
      t.references :event
      t.string     :locale
      t.string     :title
      t.text 	   :description
      t.timestamps
    end
  end
end
