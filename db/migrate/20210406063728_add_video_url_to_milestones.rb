class AddVideoUrlToMilestones < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :video_url, :string
  end
end
