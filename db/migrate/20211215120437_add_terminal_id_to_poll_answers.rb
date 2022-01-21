class AddTerminalIdToPollAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :poll_answers, :terminal_id, :integer
  end
end
