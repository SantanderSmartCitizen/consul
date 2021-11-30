class AddMeetsFeasibilityRequirementsToBudgetInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :meets_feasibility_requirements, :boolean
  end
end
