class AddLegalBasesPageToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :legal_bases_page, :string
  end
end
