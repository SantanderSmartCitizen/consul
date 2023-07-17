class AddStatusAndRequestAndResponseToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :status, :string
    add_column :complaints, :request_type, :string
    add_column :complaints, :request_code, :string
    add_column :complaints, :request_name, :string
    add_column :complaints, :request, :text
    add_column :complaints, :response_code, :string
    add_column :complaints, :response_name, :string
    add_column :complaints, :response, :text
  end
end
