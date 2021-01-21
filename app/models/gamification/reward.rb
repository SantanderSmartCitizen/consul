class Gamification::Reward < ApplicationRecord
  belongs_to :gamification
  has_many :gamification_requested_rewards, inverse_of: :gamification_reward, dependent: :restrict_with_error, class_name: "Gamification::RequestedReward", foreign_key: "gamification_reward_id"

  include Measurable
  include Documentable
  include Linkable

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  # validates :gamification_id, presence: true
  validates_translation :title, presence: true, length: { in: 3..Gamification::Reward.title_max_length }
  # validates_translation :description, presence: true, length: { in: 10..Gamification::Reward.description_max_length }
  validates :minimum_score, presence: true, length: { in: 1..10 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def self.active_for(user_id)
    active.joins("INNER JOIN gamification_user_rankings ON gamification_rewards.gamification_id = gamification_user_rankings.gamification_id and gamification_rewards.minimum_score <= gamification_user_rankings.score")
    .where(gamification_user_rankings: { user_id: user_id })
  end

  def active_for?(user)
    minimum_score <= gamification.user_score(user)
  end

  def requested_for?(user)
    user_requested_rewards = gamification_requested_rewards.where(user: user)
    return false if user_requested_rewards.nil?
    user_requested_rewards.count > 0
  end

  def executed_for?(user)
    user_requested_rewards = gamification_requested_rewards.where(user: user).where.not(executed_at: nil)
    return false if user_requested_rewards.nil?
    user_requested_rewards.count > 0
  end

end
