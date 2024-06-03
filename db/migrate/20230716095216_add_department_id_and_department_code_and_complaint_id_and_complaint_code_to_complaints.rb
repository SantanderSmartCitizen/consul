class AddDepartmentIdAndDepartmentCodeAndComplaintIdAndComplaintCodeToComplaints < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :department_id, :string
    add_column :complaints, :department_code, :string
    add_column :complaints, :complaint_id, :string
    add_column :complaints, :complaint_code, :string
  end
end
