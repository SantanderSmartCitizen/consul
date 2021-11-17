class AddEstimatedPriceToBudgetInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :estimated_price, :integer, limit:8
  end
end
