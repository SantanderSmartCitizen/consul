class AddCitizenTypeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :citizen_type, :string
  end
end
