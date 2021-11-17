class AddMaintenanceCostToBudgetInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :maintenance_cost, :integer, limit:8
  end
end
