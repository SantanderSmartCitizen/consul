class Gamification::UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :gamification_action, class_name: "Gamification::Action"

  validates :user, presence: true
  validates :gamification_action, presence: true
  validates :action_score, presence: true, length: { in: 1..6 }
end
