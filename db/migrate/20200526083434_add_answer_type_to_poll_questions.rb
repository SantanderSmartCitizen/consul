class AddAnswerTypeToPollQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :poll_questions, :answer_type, :string, default: 'simple'
  end
end
