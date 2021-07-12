class AddVotingSystemAndMaxVotesToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :voting_system, :string
    add_column :budgets, :max_votes, :integer
  end
end
