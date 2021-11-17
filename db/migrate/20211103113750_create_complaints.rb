class CreateComplaints < ActiveRecord::Migration[5.0]
  def change
    create_table :complaints do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :type
      t.string :department
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
