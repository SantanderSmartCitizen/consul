class Gamification::RequestedReward < ApplicationRecord
  belongs_to :gamification_reward, class_name: "Gamification::Reward"
  belongs_to :user
  belongs_to :administrator

  validates :gamification_reward, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :asc) }

  scope :pending, -> { where(executed_at: nil) }
  scope :done, -> { where.not(executed_at: nil) }
end
