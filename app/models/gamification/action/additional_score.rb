class Gamification::Action::AdditionalScore < ApplicationRecord
  belongs_to :gamification_action, class_name: "Gamification::Action"
  belongs_to :process, polymorphic: true

  validates :gamification_action, presence: true
  validates :process_id, presence: true
  validates :additional_score, presence: true, length: { in: 1..6 }

  validates_uniqueness_of :process_id, scope: [:gamification_action_id]
end
