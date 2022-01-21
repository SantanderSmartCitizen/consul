class Poll::Answer < ApplicationRecord
  belongs_to :question, -> { with_hidden }, inverse_of: :answers
  belongs_to :author, ->   { with_hidden }, class_name: "User", inverse_of: :poll_answers
  belongs_to :terminal

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author, presence: true, unless: ->(a) { a.question.poll.only_terminals?}
  validates :answer, presence: true

  validates :answer, inclusion: { in: ->(a) { a.question.possible_answers }},
                     unless: ->(a) { a.question.blank? || a.question.answer_type == "free_text"}

  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_question, ->(question_id) { where(question_id: question_id) }

  def record_voter_participation(token)
    Poll::Voter.find_or_create_by(user: author, poll: poll, origin: "web", token: token)
  end
end
