class RemoveLocationFromTerminalStatuses < ActiveRecord::Migration[5.0]
  def change
    remove_column :terminal_statuses, :location, :string
  end
end
