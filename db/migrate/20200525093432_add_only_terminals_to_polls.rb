class AddOnlyTerminalsToPolls < ActiveRecord::Migration[5.0]
  def change
    add_column :polls, :only_terminals, :boolean, default: false
  end
end
