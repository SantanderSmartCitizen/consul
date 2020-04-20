class AddForumCounterToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :forums_count, :integer, default: 0
    add_index :tags, :forums_count
  end
end