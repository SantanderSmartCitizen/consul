class CreateBudgetGeozones < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_geozones do |t|
      t.string :name
      t.string :external_code

      t.timestamps
    end
  end
end
