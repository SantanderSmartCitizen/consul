class AddManagementAreaToManagers < ActiveRecord::Migration[5.0]
  def change
    add_reference :managers, :management_area, index: true, foreign_key: true
  end
end
