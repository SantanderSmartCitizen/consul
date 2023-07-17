class RemoveTypeFromComplaints < ActiveRecord::Migration[5.0]
  def change
    remove_column :complaints, :type, :string
  end
end
