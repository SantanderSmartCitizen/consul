class AddOfficialSublevelToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :official_sublevel, :string
  end
end
