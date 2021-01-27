class Gamification::Action < ApplicationRecord
  belongs_to :gamification
  has_many :gamification_action_additional_scores, inverse_of: :gamification_action, dependent: :destroy, class_name: "Gamification::Action::AdditionalScore", foreign_key: "gamification_action_id"
  has_many :gamification_user_actions, inverse_of: :gamification_action, dependent: :restrict_with_error, class_name: "Gamification::UserAction", foreign_key: "gamification_action_id"

  PROCESS_TYPES = {
    'Debate' => [ "create", "comment", "vote" ],
    'Proposal' => [ "create", "comment", "support" ],
    'Poll' => [ "answer_question", "comment" ],
    'Budget::Investment' => [ "create" ],
    'Legislation::Process' => [ "comment", "comment_debate", "create_proposal", "comment_proposal", "support_proposal" ],
    'Forum' => [ "create", "comment" ]
  }.freeze

  include Measurable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  validates :gamification_id, presence: true
  validates :key, presence: true
  validates_uniqueness_of :key, scope: [:gamification_id]
  validates_translation :title, presence: true, length: { in: 3..Gamification::Action.title_max_length }
  #validates_translation :description, presence: true, length: { in: 10..Gamification::Action.description_max_length }
  validates :score, presence: true, length: { in: 1..6 }

  validates :process_type, presence: true, unless: "operation.blank?"
  validates :operation, presence: true, unless: "process_type.blank?"
  validates_uniqueness_of :operation, scope: [:gamification_id, :process_type], unless: "process_type.blank?"
  
end
