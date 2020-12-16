class Gamification::AdditionalScore < ApplicationRecord
  belongs_to :gamification_action, class_name: "Gamification::Action"

  validates :gamification_action, presence: true
  validates :process_id, presence: true
  validates :additional_score, presence: true, length: { in: 1..6 }

end
