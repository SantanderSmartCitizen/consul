class AddRequestNumberAndExpNumberToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :request_number, :string
    add_column :complaints, :exp_number, :string
  end
end
