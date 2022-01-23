class AddLatitudeAndLongitudeToTerminalStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :terminal_statuses, :latitude, :float
    add_column :terminal_statuses, :longitude, :float
  end
end
